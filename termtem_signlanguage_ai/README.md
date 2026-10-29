# Termtem Flutter

The redesigned app requires a Supabase session before opening its main screens.
Email/password sign-in and registration use Supabase Auth. The SDK persists the
session and refreshes tokens. Logout clears local authentication and protected
navigation. Profile name/email come from the signed-in user.

Use a Flutter SDK with Dart 3.13 or newer for the resolved dependencies.

## Local browser setup

1. Copy `config/dev.example.json` to `config/dev.json` (an ignored local file).
2. Set `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` using the same Supabase project
   as Go. Use the public publishable key or legacy anon key. Never use a secret,
   service-role key, database password, or JWT signing secret in Flutter.
3. Enable the Email provider in Supabase Authentication. With email confirmation
   enabled, confirm the account before signing in. Set the confirmation redirect
   / Site URL to your app address in Supabase URL Configuration.
4. Start Go and Python from the repository root:

   ```sh
   docker compose up -d --build
   ```

   Alternatively, keep Python in Docker and run `go run .` from `backend-go`.
   Restart any existing Go process to load the browser CORS changes. Do not run
   local Go and container Go on port 8080 together.
5. From this Flutter directory:

   ```sh
   flutter pub get
   flutter run -d chrome --web-hostname localhost --web-port 3000 --dart-define-from-file=config/dev.json
   ```

Go permits browser requests from `http://localhost:3000` and
`http://127.0.0.1:3000`, including the Authorization header. Before hosting the
app elsewhere, explicitly add its trusted frontend origin to Go's BrowserCORS
configuration. Deploy the API over HTTPS.

## Video flow

Flutter requests the current Supabase token, refreshing an expired session, then
posts multipart field `video` to Go's `/api/videos/process` on port 8080. Go
verifies the token and forwards to Python. Flutter displays the returned label,
confidence, and model/mock mode. Prediction confidence is not a guarantee of
correctness. The client enforces 32 MiB, reports server errors, and bounds waiting
time. Leaving the screen closes the HTTP client; Python may continue processing
an already-submitted video.

Uploads no longer call Python directly. No prediction history/profile database
is implemented here; other redesigned feature cards and chat remain demo UI.

## Google sign-in (optional, not configured by this repository)

Keep `ENABLE_GOOGLE_LOGIN` false until configuration is complete.

1. Create a Google OAuth web client and configure Google's consent screen. Add
   Supabase's callback (`https://PROJECT_REF.supabase.co/auth/v1/callback`) to its
   authorized redirect URIs.
2. Enable Google in Supabase Authentication → Providers and enter the Google
   client ID/secret there. Never put the Google client secret in Flutter.
3. Allow `http://localhost:3000` in Supabase Authentication → URL Configuration →
   Redirect URLs. Use a stable port so redirects and the PKCE verifier share the
   same browser origin.
4. Set `ENABLE_GOOGLE_LOGIN` to true in the local config and restart Flutter.
   The button uses Supabase's browser OAuth flow and the same session gate.
5. For Android/iOS, also allow `io.termtemsl.app://login-callback/` in Supabase.
   Callback schemes are registered in the Android/iOS/macOS projects. Windows
   and Linux native OAuth callback registration is not included; use web first.

Google OAuth still requires a live provider/redirect test after dashboard setup.
Official setup: https://supabase.com/docs/guides/auth/social-login/auth-google

## Native targets

For an Android emulator, set `API_BASE_URL` to `http://10.0.2.2:8080` (also the
native Android default). Debug cleartext access is scoped to the emulator host.
Physical devices need a reachable HTTPS API URL; their localhost is the device,
not your development machine. Native runtime behavior must be verified on the
target device. macOS network and user-selected file entitlements are included.

## Verification

```sh
flutter analyze
flutter test
flutter build web --dart-define-from-file=config/dev.json
```

Before merging into `frontend/ui_redesign`, verify live sign-in, registration and
confirmation, browser reload/session restoration, video preview/upload/prediction,
logout (including from Profile), and rejection of wrong credentials. Google is a
separate verification once configured. Do not commit the local config file.
