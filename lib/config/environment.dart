class Environment {
  static const String pocketbaseUrl = String.fromEnvironment(
    'POCKETBASE_URL',
    defaultValue: 'http://127.0.0.1:8090',
  );

  // OAuth callback scheme for GitHub (custom URL scheme)
  static const String oauthCallbackScheme = 'com.geoffjay.habits';
  static const String oauthCallbackUrl = '$oauthCallbackScheme://oauth-callback';

  // Google OAuth - Server client ID from Web application credentials
  // This is the Web client ID, NOT the Android client ID
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  // Google redirect URI - must match what's configured in PocketBase
  static const String googleRedirectUri = String.fromEnvironment(
    'GOOGLE_REDIRECT_URI',
    defaultValue: 'http://127.0.0.1:8090/api/oauth2-redirect',
  );
}
