# IronForge

IronForge is a premium, offline-first workout tracker for serious lifters. The current build focuses on fast workout logging, previous-session autofill, PR detection, progress stats, editable routines, custom exercises, and a red/black IronForge UI.

## Current Status

This repository contains a functional Flutter app with local Hive persistence, Riverpod providers, GoRouter navigation, premium shared UI components, and tests for the core offline workflows.

Latest verified state:

- Branch: `main`
- Android package: `com.ironforge.app`
- Storage: local Hive, offline-first
- Sensitive permissions: none declared
- Firebase: not added
- RevenueCat: not added
- Debug APK: builds successfully

## Setup

1. Install Flutter 3.24 or newer.
2. From this folder, run:

```bash
flutter pub get
flutter run
```

3. Optional checks:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Folder Structure

```text
lib/
  main.dart
  src/
    app.dart
    core/
      app_theme.dart
      router.dart
      sample_data.dart
    features/
      exercises/
      progress/
      routines/
      workout_logger/
      onboarding/
      premium/
    shared/widgets/
```

## Implemented First

- Dark premium UI theme.
- Red/black IronForge design system.
- Premium home dashboard.
- Dense workout logger screen.
- Exercise cards and set rows.
- Same-as-last-time and smart next-set suggestions.
- PR detection.
- Rest timer and plate calculator utilities.
- Progress dashboard with period tabs and red chart.
- Exercise library with search, filters, favorites, and custom exercises.
- Programs screen with editable local routines.
- AI Coach and Pro screens as premium coming-soon surfaces.
- Regression coverage for opening the workout logger from `START WORKOUT`.

## Latest Validation

```text
flutter pub get
OK

flutter analyze
No issues found

flutter test
9 tests passed

flutter build apk --debug
build/app/outputs/flutter-apk/app-debug.apk
```

## Next Engineering Steps

- Produce final Play Store screenshots.
- Add release signing files locally.
- Prepare privacy policy and store listing review.
- Add Firebase Auth, Firestore, Storage, and sync queue when cloud sync is designed.
- Add RevenueCat entitlement checks when premium features are finalized.
- Add voice input parser.
- Add camera/progress photo flow.
- Add background rest timer notifications and haptics.
