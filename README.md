# live_app


A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Code Generation

To generate JSON serialization files, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

or

```bash
 dart run build_runner build --delete-conflicting-outputs
```


Use the following command to generate protobuf-related files.
```bash
protoc --dart_out=/protos socket_message.proto
```

## Build Scripts

All build scripts will ask for version selection before build:

- `1 = cn 91`
- `2 = yd xo`
- `3 = tk`

### Build Web App

Bash:

```bash
bash scripts/build_web.sh
```

PowerShell:

```powershell
./scripts/build_web.ps1
```

Web script notes:

- Use script instead of calling `flutter build web` directly
- Restore `pubspec.yaml` and `lib/utils/app_lang_version_utils.dart` after build

### Build Mobile App

Bash:

```bash
bash scripts/build_mobile.sh build apk --release
bash scripts/build_mobile.sh build ios --release
```

PowerShell:

```powershell
./scripts/build_mobile.ps1 build apk --release
./scripts/build_mobile.ps1 build ios --release
```

Mobile script notes:

- Use script instead of editing `pubspec.yaml` manually
- Restore `pubspec.yaml` and `lib/utils/app_lang_version_utils.dart` after build
- For `build apk`, script will:
  - remove any passed `--target-platform` argument
  - ensure `--split-per-abi` is present
  - run Flutter build once and let Flutter output split APKs in one run

## Build App Without Scripts
```bash
flutter build apk --release
```

## Build Web App Without Scripts
```bash
flutter build web --release --no-pub --no-web-resources-cdn --pwa-strategy=none
```

## Run Web App
```bash
flutter run -d chrome
```
## For app version (xo or 91)
change the applicationId in the android/app/build.gradle.kts file
change the android:label in the android/app/src/main/AndroidManifest.xml file
change the AppLangVersionUtils.getLangVersion() method in the lib/utils/app_lang_version_utils.dart file
