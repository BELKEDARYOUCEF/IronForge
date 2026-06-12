# IronForge

IronForge is a premium, offline-first workout tracker for serious lifters. The first build focuses on fast workout logging, previous-session autofill, PR detection, progress stats, and a scalable architecture for Firebase, RevenueCat, AI insights, and wearables.

## Current Status

This repository is a hand-built Flutter scaffold because Flutter is not installed on this machine. It includes the main app structure, screens, domain models, sample data, workout logger logic, progress calculations, and setup notes.

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
- Home dashboard.
- Workout logger screen.
- Exercise cards and set rows.
- Same-as-last-time and smart next-set suggestions.
- PR detection.
- Plate calculator utility.
- Progress dashboard with weekly stats and exercise trend cards.
- Exercise library screen.
- Routine and premium placeholder screens.

## Next Engineering Steps

- Add Isar or Hive persistence.
- Add Firebase Auth, Firestore, Storage, and sync queue.
- Add RevenueCat entitlement checks.
- Add voice input parser.
- Add real charts with `fl_chart`.
- Add camera/progress photo flow.
- Add background rest timer notifications and haptics.

