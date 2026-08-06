# TelePro 3

Android-only Flutter module with a smooth system call-history screen, an in-app
keypad that opens the original phone app, and incremental dashboard
synchronization. Authentication is intentionally not included.

## Run

```sh
flutter pub get
flutter run \
  --dart-define=CALL_LOG_SYNC_URL=https://api.example.com/v1/call-logs/sync
```

After your existing login succeeds, store its token and navigate to the module:

```dart
await SessionStore.saveAuthToken(tokenFromYourLoginApi);
if (context.mounted) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (_) => const HomeScreen()),
  );
}
```

The sync endpoint receives a batch under `logs`. Each log contains `id`,
`number`, `normalizedNumber`, `name`, `direction`, `startedAt`, and
`durationSeconds`. It should return a successful 2xx response only after the
batch is accepted. The backend is responsible for authoritative number
normalization and matching against the dashboard database.

No endpoint is contacted when `CALL_LOG_SYNC_URL` is omitted.

## Android permissions

The application requests phone/call-log access only when Recents is opened.
Call history is sensitive data; publish only when your Play policy declaration,
privacy policy, consent flow, and core functionality satisfy Google's rules.