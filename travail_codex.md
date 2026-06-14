# Travail Codex - IronForge

## 13 juin 2026 - /home/yobel/Documents/02_Projets/Developpement/IronForge

### Etape 1 - Toolchain Flutter Linux desktop

Travail effectue :

- Verification de Flutter : version stable 3.44.1, Dart 3.12.1.
- Activation du support Linux desktop avec `flutter config --enable-linux-desktop`.
- Generation de la plateforme Linux du projet avec `flutter create --platforms=linux .`.
- Resolution des dependances Flutter avec `flutter pub get`.

Etat :

- La cible `linux/` existe maintenant dans le projet.
- La resolution Flutter fonctionne apres acces reseau a `pub.dev`.
- La compilation Linux n'est pas encore possible parce que des paquets systeme manquent sur la machine.

Blocage restant :

```bash
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build libgtk-3-dev
```

Ces commandes demandent le mot de passe administrateur dans un vrai terminal.

### Etape 2 - Identite Android

Travail effectue :

- Changement du `namespace` Android vers `com.ironforge.app`.
- Changement du `applicationId` Android vers `com.ironforge.app`.
- Deplacement logique de `MainActivity.kt` vers le package Kotlin `com.ironforge.app`.
- Changement du nom visible Android de `ironforge` vers `IronForge`.
- Alignement de l'identifiant Linux GTK sur `com.ironforge.app`.

Package actuel :

```text
com.ironforge.app
```

### Etape 3 - Base locale offline

Travail effectue :

- Ajout de `hive` et `hive_flutter`.
- Initialisation Hive au demarrage de l'application.
- Ouverture de la box locale `workout_sessions`.
- Ajout de la serialisation locale pour `WorkoutSession`, `LoggedExercise` et `LoggedSet`.
- Creation d'un `HiveWorkoutRepository` pour lire et sauvegarder les workouts hors ligne.

Etat :

- Les workouts peuvent etre sauvegardes localement sans Firebase.
- Le repository garde un fallback memoire pour les tests/widget previews quand Hive n'est pas initialise.

### Etape 4 - Historique reel

Travail effectue :

- Ajout du provider `workoutHistoryProvider`.
- Remplacement des lectures `sampleHistory` dans le controller par l'historique du repository.
- Branchement de l'accueil sur les workouts sauvegardes.
- Branchement de l'ecran Progress sur les workouts sauvegardes.
- Ajout d'une action minimale `Finish` dans le workout logger pour sauvegarder une seance dans Hive.

Etat :

- Les stats d'accueil et de progression viennent maintenant de la base locale.
- `sample_data.dart` reste utilise pour la liste initiale d'exercices; il ne pilote plus l'historique workout.

### Etape 5 - Workout logger complet niveau local

Travail effectue :

- Ajout de l'edition des sets enregistres.
- Ajout de la suppression des sets.
- Ajout de notes par exercice.
- Ajout de notes par set dans la fenetre d'edition.
- Ajout d'un timer de repos reel apres chaque set logge.
- Ajout d'un retour haptique et d'un son lors du log d'un set.
- Ajout d'une alerte haptique et sonore a la fin du repos.
- Ajout du choix d'unite `kg` / `lbs` dans le logger.
- Conservation de la sauvegarde de fin de seance avec le bouton `Finish`.

Etat :

- Les poids sont sauvegardes en kilogrammes dans la base locale.
- L'affichage peut basculer en livres dans le logger.
- Les options avancees globales d'unite utilisateur seront a relier ensuite a l'onboarding/preferences.

### Etape 6 - Vrais graphiques

Travail effectue :

- Utilisation reelle de `fl_chart` dans l'ecran Progress.
- Ajout d'un graphique de volume par seance base sur l'historique sauvegarde.
- Ajout des libelles de dates sur l'axe horizontal.
- Ajout d'un etat vide quand aucune seance n'est encore sauvegardee.

Etat :

- L'ancien emplacement de graphique est remplace par un vrai `LineChart`.
- Le graphique depend des donnees locales Hive via `workoutHistoryProvider`.

### Etape 7 - Routines modifiables

Travail effectue :

- Ajout du modele `Routine`.
- Ajout d'un repository local Hive pour les routines.
- Ouverture de la box locale `routines` au demarrage.
- Remplacement de la liste statique par des routines sauvegardees.
- Ajout creation de routine.
- Ajout modification de routine.
- Ajout suppression de routine.
- Ajout d'une logique simple de progression configurable en kg.

Etat :

- Les routines sont maintenant gerees localement.
- La progression affichee est une regle simple : ajouter le poids configure quand les reps cibles sont atteintes.

### Etape 8 - Exercices custom et bibliotheque fonctionnelle

Travail effectue :

- Ajout de la serialisation et `copyWith` pour `Exercise`.
- Ajout d'un repository local Hive pour les exercices.
- Ouverture de la box locale `exercises` au demarrage.
- Fusion des exercices de base avec les modifications locales.
- Ajout de la recherche reelle par nom, muscle et equipement.
- Ajout de filtres fonctionnels : All, Barbell, Chest, Back, Favorites, Custom.
- Ajout favoris activables/desactivables.
- Ajout creation d'exercices utilisateur.
- Ajout modification/suppression des exercices utilisateur.
- Branchement du workout logger sur la bibliotheque reelle, donc les exercices custom sont utilisables en seance.

Etat :

- `sampleExercises` sert encore de catalogue de depart.
- Les favoris et exercices custom sont persistants localement via Hive.

### Etape 9 - Onboarding utilisateur

Travail effectue :

- Ajout du modele `UserProfile`.
- Ajout d'un repository local Hive pour le profil utilisateur.
- Ouverture de la box locale `user_profile` au demarrage.
- Ajout d'un ecran `/onboarding`.
- Ajout des choix : objectif, niveau, unite, frequence hebdomadaire, type d'entrainement.
- Ajout d'un acces depuis l'accueil avec resume du profil configure.

Etat :

- Le profil utilisateur est sauvegarde localement.
- L'unite globale est stockee dans le profil, mais le logger utilise encore son toggle local; le branchement global pourra etre affine ensuite.

### Etape 10 - Securite et vie privee

Travail effectue :

- Verification que le manifest Android ne declare pas de permissions sensibles.
- Desactivation du backup Android automatique avec `android:allowBackup="false"`.
- Desactivation de `android:fullBackupContent`.
- Ajout du document `docs/security_privacy.md`.
- Documentation des regles avant d'ajouter photos, mensurations, localisation, donnees sante ou cloud sync.

Etat :

- L'app reste locale et sans permissions sensibles.
- Les donnees Hive ne sont pas encore chiffrees; c'est acceptable pour le prototype local actuel, mais a renforcer avant toute donnee tres sensible.

### Etape 11 - Firebase plus tard

Decision :

- Firebase n'a pas ete ajoute maintenant.
- Raison : l'application locale fonctionne avec Hive et doit rester stable avant auth/cloud sync.

Preconditions avant Firebase :

- repository local teste;
- ecran de conflit/synchronisation defini;
- consentement utilisateur;
- regles Firestore/Storage;
- privacy policy mise a jour.

### Etape 12 - RevenueCat plus tard

Decision :

- RevenueCat n'a pas ete ajoute maintenant.
- Raison : il faut d'abord definir de vraies fonctionnalites premium.

Preconditions avant RevenueCat :

- liste claire des fonctions gratuites/premium;
- paywall conforme;
- restauration d'achat;
- textes Play Store;
- tests d'achat sandbox.

### Etape 13 - Build release

Travail effectue :

- Ajout de la lecture Gradle de `android/key.properties`.
- Ajout d'une configuration `signingConfigs.release`.
- Ajout de `android/key.properties.example`.
- Verification que `android/key.properties` et les fichiers `.jks` sont ignores par Git.
- Ajout du document `docs/release_build.md`.
- Verification du build Android debug.

Resultat de verification :

```text
flutter build apk --debug
build/app/outputs/flutter-apk/app-debug.apk
```

## 13 juin 2026 - Preparation depot GitHub pour analyse externe

Travail effectue :

- Mise a jour de `.gitignore`.
- Ajout des exclusions pour secrets, environnements locaux, artefacts APK/AAB, coverage, previews et notes locales.
- Verification que les fichiers locaux `app_preview.png` et `tester l’app de 3 façons` sont ignores.
- Creation du commit Git :

```text
5207a92 Complete offline IronForge app foundation
```

- Push du projet sur GitHub.

Depot GitHub :

```text
https://github.com/BELKEDARYOUCEF/IronForge
```

Branche :

```text
main
```

Framework :

```text
Flutter
```

## 14 juin 2026 - Redesign IronForge rouge/noir

Objectif :

- Transformer l'UI existante sans repartir de zero.
- Garder Hive, repositories, tests, package Android `com.ironforge.app`.
- Ne pas ajouter Firebase ni RevenueCat.

Travail effectue :

- Remplacement du theme teal par la palette IronForge rouge/noir.
- Ajout de `IFColors` et `IFText`.
- Ajout du design system : cards, chips, metric tiles, section headers, empty states, bottom nav, PR celebration.
- Ajout d'une bottom navigation persistante.
- Redesign Home dashboard.
- Redesign workout logger dense avec sets table, timer compact, plate calculator preview et PR dialog.
- Ajout des routes/ecrans `History`, `Rest Timer`, `Plate Calculator`, `AI Coach`.
- Redesign Progress avec tabs et chart rouge.
- Redesign Exercises avec search, filtres, favoris et custom exercises conserves.
- Redesign Routines en `Programs`, avec `My Programs` et `Explore`.
- Redesign Onboarding.
- Redesign Premium en surface `Coming soon`, sans achat reel.
- Ajout des dossiers assets vides necessaires au branding et aux futures images.
- Ajout de la dependance `percent_indicator`.

Validation :

```text
flutter pub get
OK

flutter analyze
No issues found

flutter test
8 tests passed

flutter build apk --debug
build/app/outputs/flutter-apk/app-debug.apk
```

Etat :

- Le projet est pret a recevoir un vrai keystore.
- Le build release Play Store demandera de creer `android/key.properties` avec les vraies valeurs privees.

### Etape 14 - Preparation Play Store

Travail effectue :

- Ajout du document `docs/play_store_prepare.md`.
- Ajout d'une description courte brouillon.
- Ajout d'une description longue brouillon.
- Ajout de la categorie recommandee.
- Ajout de la liste des captures a produire.
- Ajout d'un brouillon Data Safety.
- Ajout du document `docs/privacy_policy_draft.md`.
- Verification des permissions actuelles : aucune permission sensible declaree.

Etat :

- Les textes sont des brouillons prets a relire.
- Les screenshots finaux doivent etre produits depuis une build release signee.

### Etape 15 - Tests serieux

Travail effectue :

- Ajout de tests repository pour les workouts sauvegardes.
- Ajout de test `lastSetForExercise`.
- Ajout de tests creation/modification/suppression de routines.
- Ajout de tests exercices custom et favoris.
- Ajout de test sauvegarde du profil onboarding.
- Ajout de test ProgressStats pour volume, sets et meilleur E1RM.
- Execution de la suite complete.

Resultat :

```text
flutter test
8 tests passed
```

Verification statique :

```text
flutter analyze
No issues found
```

## 13 juin 2026 - Changement du package final

Decision utilisateur :

```text
com.ironforge.app
```

Travail effectue :

- Remplacement de l'ancien package par `com.ironforge.app`.
- Mise a jour du `namespace` Android.
- Mise a jour du `applicationId` Android.
- Deplacement de `MainActivity.kt` vers `android/app/src/main/kotlin/com/ironforge/app/`.
- Mise a jour de l'identifiant Linux GTK.
- Mise a jour des documents release et Play Store.

Verification :

```text
flutter analyze
No issues found

flutter test
8 tests passed

flutter build apk --debug
build/app/outputs/flutter-apk/app-debug.apk
```

## 14 juin 2026 - Final polish preview IronForge

Travail effectue :

- Passe de polish finale sur les surfaces restantes : Onboarding, Premium, PR celebration et edition de set.
- Remplacement des derniers composants visuellement generiques par des cards, bottom sheets et boutons du design system IronForge.
- Verification des textes non professionnels visibles dans l'app.
- Mise a jour du README pour refleter l'etat reel : app Flutter offline-first avec Hive, routines, exercices custom, progress chart et UI rouge/noir.
- Conservation de la logique Hive, repositories, providers, routes et package `com.ironforge.app`.

Validation :

```text
flutter pub get
OK

flutter analyze
No issues found

flutter test
8 tests passed

flutter build apk --debug
build/app/outputs/flutter-apk/app-debug.apk
```
