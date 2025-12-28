# Habits

A Flutter Android app for tracking personal habits with PocketBase backend authentication.

## Features

- Email/password authentication
- Google OAuth sign-in
- GitHub OAuth sign-in
- Create, edit, and delete habits
- Track daily habit completions
- View habits for past dates
- Points-based scoring system (good/bad habits)

## Requirements

- Flutter 3.38+
- Android SDK
- PocketBase server with:
  - `users` collection (default auth collection)
  - `habits` collection with fields:
    - `userId` (relation to users)
    - `name` (text)
    - `description` (text, optional)
    - `type` (select: good, bad)
    - `points` (number)
  - Google OAuth2 provider configured
  - GitHub OAuth2 provider configured

## Configuration

### Environment Variables

| Variable                  | Description                | Default                    |
| ------------------------- | -------------------------- | -------------------------- |
| `POCKETBASE_URL`          | PocketBase server URL      | `http://127.0.0.1:8090`    |
| `GOOGLE_SERVER_CLIENT_ID` | Google OAuth web client ID | (required for Google auth) |

### PocketBase Setup

1. Create a PocketBase instance
2. Enable Google and GitHub OAuth providers in Settings > Auth providers
3. Create a `habits` collection with the schema above
4. Set up collection rules for user-based access

### OAuth Provider Setup

#### Google

1. Create a project in Google Cloud Console
2. Configure OAuth consent screen
3. Create OAuth 2.0 credentials:
   - Web application client (for PocketBase)
   - Android client (for the app)
4. Add SHA-1 fingerprint to Android client:
   ```bash
   cd android && ./gradlew signingReport
   ```
5. Set the web client ID in PocketBase and as `GOOGLE_SERVER_CLIENT_ID`

#### GitHub

1. Create an OAuth App in GitHub Settings > Developer settings
2. Set Authorization callback URL to your PocketBase OAuth redirect URL
3. Add client ID and secret to PocketBase GitHub provider settings

## Build

### Development

```bash
# Run with local PocketBase
flutter run

# Run with custom PocketBase URL
flutter run --dart-define=POCKETBASE_URL=https://your-server.com
```

### Release APK

```bash
# Build release APK
flutter build apk \
  --dart-define=POCKETBASE_URL=https://your-server.com \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=your-client-id

# Install on connected device
flutter install
```

Or use the Makefile (requires `GOOGLE_CLIENT_ID` environment variable):

```bash
export GOOGLE_CLIENT_ID=your-client-id
make build
make install
```

## Architecture

- **State Management**: Provider with ChangeNotifier
- **Navigation**: GoRouter with authentication guards
- **Backend**: PocketBase SDK for auth and data
- **OAuth**:
  - Google: Native `google_sign_in` package with server auth code
  - GitHub: PocketBase realtime-based OAuth flow

## License

MIT
