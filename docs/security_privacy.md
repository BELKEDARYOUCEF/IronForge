# IronForge Security And Privacy

Date: 14 juin 2026
Project: `/home/yobel/Documents/02_Projets/Developpement/IronForge`

## Current Data Model

IronForge stores data locally with Hive:

- workout sessions;
- routines;
- exercise favorites and custom exercises;
- onboarding profile preferences.

No Firebase, cloud sync, account system, photos, location, or health platform integration is active.

AI Coach and Premium screens are local UI surfaces only. They do not call an AI API, payment SDK, analytics SDK, or cloud service.

## Android Permissions

The Android manifest currently declares no sensitive permissions.

Do not add these permissions unless a feature really needs them:

- camera;
- photos/media;
- location;
- body sensors;
- contacts;
- microphone.

Any future permission must have a user-facing reason and a Play Store justification.

## Local Storage

Android app backup is disabled in `AndroidManifest.xml`:

```xml
android:allowBackup="false"
android:fullBackupContent="false"
```

Reason: workout and body-progress data can be personal. Until encryption, export, and account controls are designed, automatic Android backup should stay disabled.

## Future Sensitive Features

Before adding photos, body measurements, location, health data, or cloud sync:

- add explicit consent screens;
- add delete/export controls;
- document retention rules;
- add encryption or platform-secure storage for sensitive records;
- update the privacy policy;
- verify Android permissions and Play Store Data Safety answers.
