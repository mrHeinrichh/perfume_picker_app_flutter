# Perfume Picker App

A modern Flutter perfume browsing and chooser app. Users can browse perfumes, filter by gender, fragrance characteristics, and notes, then open a detailed perfume page. Results are sorted by the highest number of matching filters.

## Features

- Browse hard-coded perfume products with real product images.
- Filter perfumes by Male, Female, or Unisex.
- Filter by fragrance characteristics such as woody, citrus, floral, fruity, fresh, spicy, amber, musky, and aquatic.
- Filter by top notes, middle notes, and base notes.
- Results page ranks perfumes from highest filter match count to lowest.
- Perfume detail page shows image, description, gender, characteristics, and notes.
- Editable notes catalog for admin users.
- Editable fragrance characteristics catalog for admin users.
- Admin dummy data toggle to clear or restore demo products, notes, and fragrance characteristics.
- Admin-only product management with create, edit, and delete.
- Admin can choose product images from the device gallery.
- Product, note, and characteristic changes are saved locally on the device.
- Add/edit product uses searchable note selectors for top, middle, and base notes.
- Note names are limited to 20 characters.
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

Admin can switch dummy data on or off. Turning it off clears the demo products, demo notes, and demo fragrance characteristics so the catalog managers start empty. The fixed Male, Female, and Unisex filter remains available.

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
  auth_store.dart   Auth Cubit and admin/biometric login state
  catalog.dart      Default perfume, notes, and characteristic data
  main.dart         App bootstrap, theme, and feature part registration
  models.dart       Product and filter models
  store.dart        Perfume catalog Cubit for products, notes, and characteristics
  src/
    core/           BLoC provider scopes and local persistence
    features/       Auth, browsing, results, detail, editor, and admin UI
    shared/         Reusable widgets and navigation helpers

assets/images/perfumes/
  Real perfume product images used by the catalog

release/
  Included debug APK artifact
```

## Notes

This is a simple local Flutter app. It does not use a backend database, but admin changes are saved on the device with SharedPreferences so products, notes, characteristics, and gallery-picked images remain after reopening the app.
