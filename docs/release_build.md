# IronForge Release Build

Date: 13 juin 2026
Project: `/home/yobel/Documents/02_Projets/Developpement/IronForge`

## Android Package

```text
com.ironforge.app
```

## App Name

```text
IronForge
```

## Keystore

Do not commit the real keystore or real passwords.

Create a real keystore in a private location, then create:

```text
android/key.properties
```

Use `android/key.properties.example` as the template.

## Release Build Command

```bash
flutter build appbundle --release
```

Output:

```text
build/app/outputs/bundle/release/app-release.aab
```

## Remaining Before Store Upload

- generate final launcher icons;
- verify version in `pubspec.yaml`;
- build with the real keystore;
- test install the release build on a real device;
- keep `android/key.properties` and `.jks` private.
