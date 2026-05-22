# Perfume Picker App

A modern Flutter perfume browsing and chooser app. Users can browse perfumes, filter by gender, fragrance characteristics, and notes, then open a detailed perfume page. Results are sorted by the highest number of matching filters.

## Features

- Browse hard-coded perfume products with real product images.
- Filter perfumes by Male, Female, or Unisex.
- Filter by fragrance characteristics such as woody, citrus, floral, fruity, fresh, spicy, amber, musky, and aquatic.
- Filter by top notes, middle notes, and base notes.
- Results page ranks perfumes from highest filter match count to lowest.
- Perfume detail page shows image, description, gender, characteristics, and notes.
- Admin-only product management with create, edit, and delete.
- Admin can choose product images from the device gallery.
- Optional biometric or Face ID shortcut for admin login.
- Clean modern UI with animations.

## Admin Access

Normal browsing is open by default. Only admin mode can add, edit, or delete perfume products.

Admin credentials:

```text
Username: admin
Password: Admin@1234
```

Biometric login is also available as a shortcut on supported devices with biometrics already enrolled.

## APK

A debug APK is included in the repository:

```text
release/perfume-picker-app-debug.apk
```

Install it on an Android device or emulator with:

```bash
adb install release/perfume-picker-app-debug.apk
```

If the device says there is not enough storage, free emulator/device storage or uninstall an older build first:

```bash
adb uninstall com.example.perfume_picker_app
```

## Requirements

- Flutter SDK
- Dart SDK bundled with Flutter
- Android Studio or Android SDK for Android builds
- A configured emulator or Android device

## Run Locally

```bash
flutter pub get
flutter run
```

## Build APK

```bash
flutter build apk --debug
```

The generated APK will be available at:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Tests

```bash
flutter analyze
flutter test
```

## Project Structure

```text
lib/
  auth_store.dart   Admin login and biometric authentication logic
  catalog.dart      Hard-coded perfume product data
  main.dart         App UI, pages, filters, CRUD screens, navigation
  models.dart       Product and filter models
  store.dart        In-memory product store

assets/images/perfumes/
  Real perfume product images used by the catalog

release/
  Included debug APK artifact
```

## Notes

This is a simple local Flutter app. Product data is hard-coded and stored in memory while the app is running. It does not use a backend database.
