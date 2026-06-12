# Rapport de travail Codex - IronForge

Date du rapport : 12 juin 2026

Ce rapport documente le travail retrouve sur l'application Android/Flutter **IronForge** apres interruption du PC. Il se base sur les fichiers du projet, les dates de modification, les traces Flutter/Dart, le SDK Android local et les verifications relancees aujourd'hui.

Je n'ai pas continue le developpement du prompt. J'ai seulement audite l'existant, verifie le code et documente l'etat.

## Emplacement du projet

Application :

```text
/home/yobel/Documents/02_Projets/Developpement/IronForge
```

Important : ce dossier n'est pas un depot Git actuellement. Les commandes `git status` et `git log` echouent avec :

```text
fatal: not a git repository
```

Donc il n'y a pas d'historique Git/commit local pour cette application.

## Le dossier `/home/yobel/Android`

Le dossier :

```text
/home/yobel/Android
```

n'est pas l'application IronForge. C'est le **SDK Android local** utilise par Flutter/Gradle pour compiler l'application Android.

Il contient notamment :

```text
/home/yobel/Android/Sdk/cmdline-tools
/home/yobel/Android/Sdk/platform-tools
/home/yobel/Android/Sdk/emulator
/home/yobel/Android/Sdk/platforms/android-35
/home/yobel/Android/Sdk/platforms/android-36
/home/yobel/Android/Sdk/build-tools/35.0.0
/home/yobel/Android/Sdk/build-tools/36.0.0
/home/yobel/Android/Sdk/ndk/28.2.13676358
/home/yobel/Android/Sdk/cmake/3.22.1
/home/yobel/Android/Sdk/licenses
```

Taille mesuree :

```text
Android SDK : 3.9G
```

Ce dossier est normal pour un projet Flutter Android. Il sert a compiler, lancer ADB, utiliser l'emulateur, gerer les licences Android et construire les APK.

## Travail retrouve

Les timestamps montrent un travail principal le **11 juin 2026**, environ entre **13:04 et 15:31**.

Elements crees ou presents :

- projet Flutter `IronForge` ;
- structure `lib/src/...` en architecture feature-first ;
- configuration Flutter/Android ;
- tests unitaires et widget ;
- build web genere ;
- build Android debug genere le 12 juin pendant cet audit ;
- documentation `README.md`, `PROJECT_PROMPT.md`, `ORIGINAL_PROMPT.md`.

Fichiers principaux :

```text
pubspec.yaml
analysis_options.yaml
README.md
PROJECT_PROMPT.md
ORIGINAL_PROMPT.md
lib/main.dart
lib/src/app.dart
lib/src/core/router.dart
lib/src/core/app_theme.dart
lib/src/core/sample_data.dart
lib/src/shared/widgets/forge_shell.dart
lib/src/features/workout_logger/
lib/src/features/exercises/
lib/src/features/progress/
lib/src/features/routines/
lib/src/features/premium/
test/widget_test.dart
test/workout_logger/workout_math_test.dart
android/
web/
```

## Ce que l'application fait actuellement

IronForge est un prototype Flutter d'application mobile de suivi musculation.

Objectif produit :

- permettre de demarrer un entrainement rapidement ;
- ajouter des exercices ;
- enregistrer des series avec poids, repetitions et RPE ;
- reutiliser les valeurs de la derniere seance ;
- suggerer une surcharge progressive ;
- detecter des PR via estimation de 1RM ;
- afficher un tableau de progression ;
- presenter une bibliotheque d'exercices ;
- presenter des routines ;
- preparer une page premium.

### Ecran accueil

Fichier :

```text
lib/src/features/workout_logger/presentation/home_screen.dart
```

Fonctions :

- affiche le nom IronForge ;
- message de motivation ;
- bouton `START WORKOUT` ;
- cartes statistiques fictives : streak, volume hebdo, PRs, consistency ;
- navigation vers Progress, Exercise Library, Routines, Premium.

### Workout Logger

Fichiers :

```text
lib/src/features/workout_logger/presentation/workout_logger_screen.dart
lib/src/features/workout_logger/presentation/workout_controller.dart
lib/src/features/workout_logger/domain/workout.dart
lib/src/features/workout_logger/domain/workout_math.dart
```

Fonctions presentes :

- demarrage d'un workout via l'ecran ;
- ajout rapide d'exercices depuis une liste sample ;
- affichage des exercices ajoutes ;
- ajout de series avec poids, reps, RPE ;
- bouton `Same last` ;
- bouton `Smart +` ;
- calcul du volume ;
- calcul de l'E1RM ;
- detection PR basee sur l'historique sample ;
- calculateur de plaques par cote ;
- modeles de types de series : standard, warmup, drop set, rest-pause, myo-rep, superset, giant set.

Limite importante :

- les donnees ne sont pas encore sauvegardees dans une vraie base locale ;
- l'historique vient de `sample_data.dart` ;
- si l'application est fermee, le workout courant n'est pas persiste.

### Exercise Library

Fichiers :

```text
lib/src/features/exercises/domain/exercise.dart
lib/src/features/exercises/presentation/exercise_library_screen.dart
```

Fonctions presentes :

- modele `Exercise` ;
- liste d'exercices sample ;
- champ de recherche visuel ;
- chips de filtres visuels ;
- affichage muscle/equipement/favori.

Limites :

- pas encore 1000 exercices ;
- recherche/filtres pas encore connectes a une logique ;
- pas encore d'ajout d'exercice utilisateur ;
- pas encore de videos de forme.

### Progress

Fichiers :

```text
lib/src/features/progress/domain/progress_stats.dart
lib/src/features/progress/presentation/progress_screen.dart
```

Fonctions presentes :

- calcul du volume total ;
- calcul du nombre de sets ;
- calcul du meilleur E1RM pour un exercice ;
- cartes de progression ;
- emplacement prevu pour chart `fl_chart`.

Limites :

- pas encore de vrais graphiques ;
- pas encore d'historique reel ;
- pas encore de photos, mensurations ou timeline complete.

### Routines

Fichier :

```text
lib/src/features/routines/presentation/routines_screen.dart
```

Fonctions presentes :

- liste de routines sample : PPL, Upper Lower, Strong 5x5, Powerbuilding, Bro Split ;
- bouton `BUILD CUSTOM ROUTINE` visuel.

Limites :

- pas encore de builder reel ;
- pas encore de drag-and-drop ;
- pas encore de logique de progression automatique.

### Premium

Fichiers :

```text
lib/src/features/premium/domain/entitlement.dart
lib/src/features/premium/presentation/premium_screen.dart
```

Fonctions presentes :

- ecran de presentation premium ;
- prix affiche ;
- liste de fonctionnalites premium ;
- modele simple `Entitlement`.

Limites :

- pas de RevenueCat ;
- pas de paiement ;
- pas de Firebase ;
- pas de vraie restriction free/premium.

## Architecture actuelle

Stack utilisee :

```text
Flutter 3.44.1
Dart 3.12.1
Riverpod
GoRouter
intl
uuid
fl_chart
flutter_lints
```

Structure :

```text
lib/
  main.dart
  src/
    app.dart
    core/
      app_theme.dart
      router.dart
      sample_data.dart
    shared/widgets/
      forge_shell.dart
    features/
      workout_logger/
      exercises/
      progress/
      routines/
      premium/
```

Cette structure est saine pour continuer : elle separe les features, le theme, le routing, les modeles de domaine et les ecrans.

## Installations et outils utilises

### Flutter SDK

Emplacement :

```text
/home/yobel/.local/flutter-sdk/flutter
```

Version :

```text
Flutter 3.44.1
Dart 3.12.1
DevTools 2.57.0
```

Taille :

```text
3.7G
```

Archive retrouvee :

```text
/home/yobel/.local/flutter-sdk/flutter_linux_3.44.1-stable.tar.xz
```

Utilite :

- compiler et lancer l'application Flutter ;
- gerer les dependances Dart ;
- generer le projet Android ;
- executer `flutter analyze`, `flutter test`, `flutter build`.

### Android SDK

Emplacement :

```text
/home/yobel/Android/Sdk
```

Version vue par Flutter :

```text
Android SDK version 36.0.0
```

Composants :

- command-line tools ;
- platform-tools avec `adb` ;
- emulator ;
- platforms Android 35 et 36 ;
- build-tools 35.0.0 et 36.0.0 ;
- NDK 28.2.13676358 ;
- CMake 3.22.1 ;
- licences Android acceptees.

Archive retrouvee :

```text
/home/yobel/.local/downloads/android-commandlinetools.zip
```

Utilite :

- compiler l'APK Android ;
- fournir Gradle/Flutter avec les plateformes Android ;
- utiliser ADB/emulateur ;
- accepter les licences Android.

### Java / JDK

Emplacement :

```text
/home/yobel/.local/jdk
```

Version :

```text
OpenJDK Temurin 21.0.11+10 LTS
```

Archive retrouvee :

```text
/home/yobel/.local/downloads/temurin21.tar.gz
```

Utilite :

- requis par Gradle et Android build tools ;
- utilise par Flutter pour compiler Android.

### Chrome for Testing

Emplacement :

```text
/home/yobel/.local/chrome-for-testing/chrome-linux64/chrome
```

Archive retrouvee :

```text
/home/yobel/.local/downloads/chrome-linux64.zip
```

Utilite :

- cible Flutter web ;
- verification et build web.

### Gradle

Wrapper du projet :

```text
android/gradle/wrapper/gradle-wrapper.properties
```

Version :

```text
Gradle 9.1.0
```

Plugins Android/Kotlin :

```text
Android Gradle Plugin 9.0.1
Kotlin Android 2.3.20
```

Utilite :

- compilation Android ;
- assemblage APK ;
- resolution des dependances Android.

## Verifications effectuees le 12 juin 2026

### Flutter version

Commande :

```bash
flutter --version
```

Resultat :

```text
Flutter 3.44.1
Dart 3.12.1
```

### Flutter doctor

Commande :

```bash
flutter doctor -v
```

Resultat final hors sandbox :

```text
Flutter : OK
Android toolchain : OK
Chrome : OK
Connected device : OK, Linux et Chrome disponibles
Network resources : OK
Linux desktop toolchain : incomplet
```

Problemes restants du doctor :

- `clang++` manquant ;
- `cmake` systeme manquant pour Linux desktop ;
- `ninja` manquant ;
- bibliotheques GTK 3 dev manquantes.

Impact :

- cela gene le build Linux desktop ;
- cela ne bloque pas le build Android ;
- cela ne bloque pas Flutter web/Chrome.

### Analyse statique

Commande :

```bash
flutter analyze
```

Resultat :

```text
No issues found
```

### Tests

Commande :

```bash
flutter test
```

Dans le sandbox, les tests ont echoue parce que le runner Flutter devait ouvrir un socket local `127.0.0.1`, bloque par l'environnement.

Relance hors sandbox :

```text
3 tests passed
```

Tests couverts :

- calculateur de plaques ;
- surcharge progressive ;
- rendu de l'ecran accueil.

### Build Android debug

Commande :

```bash
flutter build apk --debug
```

Dans le sandbox, Gradle a echoue car il ne pouvait pas determiner une IP wildcard utilisable.

Relance hors sandbox :

```text
Built build/app/outputs/flutter-apk/app-debug.apk
```

APK genere :

```text
build/app/outputs/flutter-apk/app-debug.apk
```

Taille :

```text
140M
```

Pendant ce build, CMake 3.22.1 a ete installe automatiquement dans :

```text
/home/yobel/Android/Sdk/cmake/3.22.1
```

### Build web existant

Un build web existait deja :

```text
build/web/main.dart.js
```

Taille :

```text
2.5M
```

Date :

```text
11 juin 2026 15:16
```

## Ce qui est complet

- Projet Flutter cree.
- Structure de dossiers propre.
- Theme sombre premium initial.
- Routing avec GoRouter.
- State management avec Riverpod.
- Ecran accueil.
- Workout logger de base.
- Modeles workout/exercise/set.
- Calculateur de plaques.
- Estimation E1RM.
- Moteur simple de surcharge progressive.
- Detection PR simple.
- Ecran library d'exercices.
- Ecran progress.
- Ecran routines.
- Ecran premium.
- Tests unitaires et widget.
- Analyse Flutter OK.
- APK debug compilable.

## Ce qui n'est pas encore complet

Le prompt demande une application "production-ready". L'etat actuel est plutot un **MVP/prototype solide**, pas encore une application finale.

Manquant important :

- vraie persistance offline avec Isar ou Hive ;
- sauvegarde des workouts apres fermeture de l'app ;
- historique complet ;
- vraie recherche d'exercices ;
- 1000+ exercices ;
- videos d'exercices ;
- exercices custom ;
- vrais graphiques `fl_chart` ;
- timeline des workouts ;
- mensurations et photos ;
- routines modifiables ;
- drag-and-drop ;
- logique de programme automatique ;
- rest timer vivant avec vibration/son ;
- haptics ;
- voice input ;
- Firebase ;
- RevenueCat ;
- compte utilisateur ;
- cloud sync ;
- permissions camera/audio/localisation ;
- exports CSV/Health/Fit/Strava ;
- notifications PR Hunter ;
- Apple Watch/Wear OS ;
- nutrition ;
- leaderboards ;
- onboarding complet ;
- vrais etats loading/error ;
- signature release Android ;
- applicationId definitif.

## Points techniques a surveiller

### 1. Mutabilite dans le state Riverpod

Dans `WorkoutController`, les listes internes sont modifiees directement puis l'etat est reconstruit.

Exemple de risque :

- `state.exercises.add(...)`
- `exercise.sets.add(...)`

Ca fonctionne pour ce prototype, mais pour une app robuste il faudra passer a des modeles immutables ou a des copies profondes pour eviter les bugs d'etat.

### 2. Repository pas encore branche

`WorkoutRepository` existe mais le controller utilise encore `sampleHistory` directement.

Il faudra injecter un repository Riverpod et brancher une vraie implementation locale.

### 3. Donnees sample seulement

Les stats, PRs et "last set" reposent sur `sample_data.dart`.

Le comportement est demonstratif, pas encore reel.

### 4. `applicationId` temporaire

Actuellement :

```text
com.example.ironforge
```

Pour publier, il faudra un vrai identifiant, par exemple :

```text
com.belkedaryoucef.ironforge
```

### 5. Release signee non configuree

Le build release utilise encore la signature debug dans `android/app/build.gradle.kts`.

Pour Play Store, il faudra :

- keystore ;
- configuration signing release ;
- gestion securisee des secrets.

### 6. Assets declares mais dossiers vides/absents

`pubspec.yaml` declare :

```yaml
assets:
  - assets/images/
  - assets/animations/
```

Mais je n'ai pas trouve de fichiers dans `assets/`.

Si les dossiers n'existent pas ou restent vides selon le contexte de build, cela peut devenir une source d'erreur plus tard. A verifier avant d'ajouter des assets Rive/Lottie/images.

## Ce qu'il faut savoir sur le prompt

Le prompt est ambitieux et donne une bonne direction produit, mais il a des problemes pratiques.

### Probleme 1 : trop large pour une seule passe

Il demande en meme temps :

- app mobile complete ;
- offline-first ;
- Firebase ;
- RevenueCat ;
- AI ;
- wearables ;
- Health/Fit/Strava ;
- progress photos ;
- voice input ;
- 1000+ exercices ;
- videos ;
- community feed ;
- leaderboards ;
- widgets ;
- app production-ready.

Ce n'est pas realiste comme une seule etape. Il faut le decouper en milestones.

### Probleme 2 : "production-ready" est contradictoire avec "Start building it now"

Une vraie app production-ready demande :

- comptes Firebase/RevenueCat ;
- design system complet ;
- politique de confidentialite ;
- securite des donnees ;
- gestion des permissions ;
- tests approfondis ;
- signature Android ;
- CI/CD ;
- validation Play Store/App Store.

Le prompt pousse l'IA a produire une grosse maquette rapidement, pas un produit final valide.

### Probleme 3 : donnees fitness et photos = sujet sensible

Progress photos, mensurations, localisation gym, health exports, wearables et nutrition impliquent :

- vie privee ;
- stockage securise ;
- consentement utilisateur ;
- suppression/export des donnees ;
- politique de confidentialite ;
- potentiellement exigences Google Play/App Store.

Il faut traiter ca serieusement avant production.

### Probleme 4 : "1000+ exercices avec videos"

Il faut verifier les droits :

- videos YouTube integrees ;
- videos locales ;
- descriptions/form instructions ;
- images et miniatures.

On ne peut pas simplement copier une base commerciale ou des videos sans droits.

### Probleme 5 : ton "gym bro"

La direction de marque est claire, mais "gym bros", "hype beast", memes, langage agressif peuvent limiter l'audience ou poser probleme dans certains contextes App Store/marketing.

Conseil : garder le mode agressif comme option "Gym bro mode", mais garder le ton par defaut professionnel.

## Recommandation de suite

Ne pas continuer directement toutes les features du prompt.

Ordre recommande :

1. Initialiser Git pour IronForge.
2. Nettoyer/valider `.gitignore`.
3. Brancher une vraie persistance locale Hive ou Isar.
4. Rendre le workout logger fiable : edit/delete sets, notes, rest timer, save session.
5. Ajouter historique reel.
6. Ajouter charts reels.
7. Ajouter routines editables.
8. Ajouter premium gates simples sans paiement.
9. Ajouter Firebase/RevenueCat seulement apres MVP local stable.

## Etat final apres audit

Etat actuel :

- application localisee ;
- code audite ;
- environnement Flutter/Android verifie ;
- tests OK ;
- analyse OK ;
- APK debug genere ;
- dossier Android explique ;
- prompt analyse ;
- aucun developpement supplementaire du prompt effectue.

Fichier APK disponible :

```text
/home/yobel/Documents/02_Projets/Developpement/IronForge/build/app/outputs/flutter-apk/app-debug.apk
```

