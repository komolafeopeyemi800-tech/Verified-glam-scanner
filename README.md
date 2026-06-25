# Verified Glam (beauty_master)

Flutter UI template for a beauty salon booking app.

## Requirements

- Flutter SDK (stable, Dart 3.x) — project tested with Flutter at `C:\Users\zenit\flutter`
- Android Studio with JDK 17
- Android SDK (API 33+ emulator recommended)

## Setup

1. Ensure `android/local.properties` includes:

   ```properties
   sdk.dir=C:\\Users\\zenit\\AppData\\Local\\Android\\Sdk
   flutter.sdk=C:\\path\\to\\your\\flutter
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   dart run build_runner build
   ```

3. Start an Android emulator (Device Manager in Android Studio).

4. Run:

   ```bash
   flutter run -d emulator-5554
   ```

   Or build and install:

   ```bash
   flutter build apk --debug
   adb install -r build/app/outputs/flutter-apk/app-debug.apk
   ```

## Assets

See [ASSETS.md](ASSETS.md) for the image audit. Placeholder PNGs are included; replace with original ProKit artwork for production.

## Maps

Set your Google Maps API key in `android/app/src/main/res/values/google_maps_api.xml`.
