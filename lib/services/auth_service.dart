import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';

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

  String? get currentUserAvatarUrl {
    final user = currentUser;
    if (user == null) return null;

    final avatar = user.getStringValue('avatar');
    if (avatar.isEmpty) return null;

    // PocketBase file URL format: {baseUrl}/api/files/{collectionId}/{recordId}/{filename}
    return _pb.files.getUrl(user, avatar).toString();
  }

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
    // Use PocketBase's built-in OAuth2 flow with realtime subscription
    // GitHub callback URL must be set to: {POCKETBASE_URL}/api/oauth2-redirect
    // e.g., https://admin.geoffjay.com/api/oauth2-redirect
    final authData = await _pb.collection('users').authWithOAuth2(
      'github',
      (url) async {
        // Open the OAuth URL in the browser
        // PocketBase handles the redirect and sends result via realtime
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
      },
      scopes: ['read:user', 'user:email'],
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
