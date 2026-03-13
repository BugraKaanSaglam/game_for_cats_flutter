# Release And Config

## Local Development

```bash
flutter pub get
flutter run
```

## Quality Gate

```bash
make quality
```

Equivalent commands:

```bash
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
```

Integration smoke test on macOS:

```bash
flutter test integration_test -d macos
```

## Coverage

```bash
make coverage
```

This generates:

- `coverage/lcov.info`

Optional HTML report:

```bash
genhtml coverage/lcov.info -o coverage/html
```

## Crash Reporting

Crash reporting is disabled by default.

To enable Sentry:

```bash
flutter run --dart-define=SENTRY_DSN=your_dsn_here
```

For CI or release builds:

```bash
flutter build apk --dart-define=SENTRY_DSN=your_dsn_here
flutter build ios --dart-define=SENTRY_DSN=your_dsn_here
```

## GitHub Actions

The CI workflow:

- installs Flutter `3.38.5`
- resolves packages
- verifies formatting
- runs static analysis
- runs widget/unit/golden tests
- runs integration smoke tests
- uploads coverage artifact

Workflow file:

- `.github/workflows/flutter_ci.yml`

## Suggested Release Checklist

1. `flutter pub get`
2. `dart format --set-exit-if-changed lib test integration_test`
3. `flutter analyze`
4. `flutter test`
5. `flutter test integration_test -d macos`
6. `flutter test --coverage`
7. verify `README.md` and docs are current
8. verify version bump in `pubspec.yaml`
9. verify DSN/config strategy for target environment
10. build target artifacts

## Configuration Surface

Current explicit runtime configuration:

- `SENTRY_DSN`: optional crash reporting backend DSN

Future expansion candidates:

- analytics backend key
- environment label (`dev`, `staging`, `prod`)
- feature flags for experimental game modes
