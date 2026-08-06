# TelePro 3

Android-only Flutter client with a smooth animated login, system call history,
an in-app keypad that opens the original phone app, and incremental dashboard
synchronization.

## Run

```sh
flutter pub get
flutter run \
  --dart-define=CALL_LOG_SYNC_URL=https://api.example.com/v1/call-logs/sync
```

The existing authentication flow should call:

```dart
await SessionStore.saveAuthToken(tokenFromYourLoginApi);
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
