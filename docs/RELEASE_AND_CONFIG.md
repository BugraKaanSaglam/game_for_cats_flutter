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

## GitHub Actions

The CI workflow:

- installs Flutter `3.38.5`
- resolves packages
- verifies formatting
- runs static analysis
- runs widget/unit tests with coverage
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
6. `flutter test --coverage --exclude-tags=golden`
7. `flutter test test/golden/app_golden_test.dart`
8. verify `README.md` and docs are current
9. verify version bump in `pubspec.yaml`
10. build target artifacts

## App Review Posture

Current release posture is intentionally simple:

- local-first experience with no backend dependency during review
- game-first home screen and gameplay flow
- no connectivity gating for core functionality
- metadata and screenshots should focus on the hunt experience, not utility screens

## Configuration Surface

Current explicit runtime configuration is intentionally minimal.

Future expansion candidates:

- analytics backend key
- environment label (`dev`, `staging`, `prod`)
- feature flags for experimental game modes
