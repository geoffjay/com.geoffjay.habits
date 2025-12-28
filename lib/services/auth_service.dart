import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pocketbase/pocketbase.dart';

import '../config/environment.dart';

class AuthService {
  static const String _authKey = 'pb_auth';

  final PocketBase _pb;
  final FlutterSecureStorage _storage;
  final GoogleSignIn _googleSignIn;

  AuthService()
      : _pb = PocketBase(Environment.pocketbaseUrl),
        _storage = const FlutterSecureStorage(),
        _googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
          serverClientId: Environment.googleServerClientId,
        );

  PocketBase get pb => _pb;

  bool get isAuthenticated => _pb.authStore.isValid;

  RecordModel? get currentUser => _pb.authStore.record;

  Future<void> restoreSession() async {
    final authData = await _storage.read(key: _authKey);
    if (authData != null) {
      final data = jsonDecode(authData);
      _pb.authStore.save(data['token'], RecordModel.fromJson(data['record']));
    }
  }

  Future<void> _saveSession() async {
    if (_pb.authStore.isValid) {
      await _storage.write(
        key: _authKey,
        value: jsonEncode({
          'token': _pb.authStore.token,
          'record': _pb.authStore.record?.toJson(),
        }),
      );
    }
  }

  Future<void> _clearSession() async {
    await _storage.delete(key: _authKey);
  }

  Future<RecordModel> loginWithEmail(String email, String password) async {
    final authData = await _pb.collection('users').authWithPassword(
          email,
          password,
        );
    await _saveSession();
    return authData.record;
  }

  Future<RecordModel> registerWithEmail(
    String email,
    String password,
    String passwordConfirm,
  ) async {
    await _pb.collection('users').create(body: {
      'email': email,
      'password': password,
      'passwordConfirm': passwordConfirm,
    });
    return loginWithEmail(email, password);
  }

  Future<RecordModel> loginWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in was cancelled');
    }

    final serverAuthCode = googleUser.serverAuthCode;
    if (serverAuthCode == null) {
      throw Exception('Failed to get server auth code from Google');
    }

    // Native Google Sign-In doesn't use PKCE, so we pass empty code verifier
    // For installed apps, use the OOB redirect URI
    final authData = await _pb.collection('users').authWithOAuth2Code(
          'google',
          serverAuthCode,
          '', // No code verifier for native sign-in
          'urn:ietf:wg:oauth:2.0:oob', // Standard redirect for installed apps
        );

    await _saveSession();
    return authData.record;
  }

  Future<RecordModel> loginWithGithub() async {
    const githubRedirectUri = 'http://localhost/callback';

    final authMethods = await _pb.collection('users').listAuthMethods();
    final providerConfig = authMethods.oauth2.providers.firstWhere(
      (p) => p.name == 'github',
      orElse: () => throw Exception('GitHub provider not configured in PocketBase'),
    );

    final authUrl = Uri.parse(providerConfig.authURL).replace(
      queryParameters: {
        ...Uri.parse(providerConfig.authURL).queryParameters,
        'redirect_uri': githubRedirectUri,
      },
    );

    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: 'http',
    );

    final uri = Uri.parse(result);
    final code = uri.queryParameters['code'];

    if (code == null) {
      throw Exception('OAuth code not found in callback');
    }

    final authData = await _pb.collection('users').authWithOAuth2Code(
          'github',
          code,
          providerConfig.codeVerifier,
          githubRedirectUri,
        );

    await _saveSession();
    return authData.record;
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    _pb.authStore.clear();
    await _clearSession();
  }
}
