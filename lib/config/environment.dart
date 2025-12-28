class Environment {
  static const String pocketbaseUrl = String.fromEnvironment(
    'POCKETBASE_URL',
    defaultValue: 'http://127.0.0.1:8090',
  );

  static const String oauthCallbackScheme = 'com.geoffjay.habits';
  static const String oauthCallbackUrl = '$oauthCallbackScheme://oauth-callback';
}
