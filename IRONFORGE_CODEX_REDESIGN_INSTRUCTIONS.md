# IRONFORGE — Plan de travail professionnel par phases pour Codex

Repo GitHub : `https://github.com/BELKEDARYOUCEF/IronForge`
Branche : `main`
Framework : `Flutter`
Package Android : `com.ironforge.app`
Commit redesign actuel : `89bb362 Redesign IronForge UI in red black style`

---

# RÈGLE ABSOLUE POUR CODEX

Tu ne dois PAS tout faire d’un coup.

Tu dois travailler phase par phase.
Quand l’utilisateur te demande une phase, tu fais uniquement cette phase, tu valides, tu commits, puis tu t’arrêtes.

Ne commence jamais la phase suivante sans instruction explicite de l’utilisateur.

À chaque phase :

1. Lis les fichiers nécessaires.
2. Fais uniquement le travail demandé.
3. Ne casse pas les fonctionnalités existantes.
4. Exécute les commandes de validation demandées.
5. Corrige les erreurs.
6. Fais un commit clair.
7. Résume exactement ce qui a été fait.
8. Stop.

---

# ORDRE DE LECTURE OBLIGATOIRE

Avant toute modification, lis dans cet ordre :

1. `IRONFORGE_CODEX_REDESIGN_INSTRUCTIONS.md`
2. `travail_codex.md`
3. `README.md`
4. `pubspec.yaml`
5. `lib/src/core/app_theme.dart`
6. `lib/src/core/router.dart`
7. `lib/src/shared/widgets/`
8. `lib/src/features/`

---

# CONTEXTE IMPORTANT

L’app est déjà offline-first avec Hive.

Ne pas ajouter maintenant :

* Firebase
* RevenueCat
* Cloud Sync
* Login
* Camera
* Location
* Health sensors
* Microphone
* Contacts
* Permissions Android sensibles

Ne pas casser :

* Hive
* repositories existants
* providers existants
* tests existants
* package Android `com.ironforge.app`
* routines locales
* exercices custom
* favoris
* onboarding local
* workout history local

Le problème actuel n’est pas la logique.
Le problème est que l’UI reste trop simple par rapport à la preview.

Objectif : rendre l’app beaucoup plus professionnelle, dense, premium, proche visuellement de la preview IronForge rouge/noir.

---

# STYLE VISUEL FINAL À ATTEINDRE

L’app doit ressembler à la preview envoyée :

* noir très profond ;
* rouge IronForge dominant ;
* cards compactes ;
* bordures fines ;
* layout dense mais lisible ;
* style brutalist premium ;
* look app commerciale prête pour App Store / Play Store ;
* pas de grands espaces vides ;
* pas de composants Flutter génériques visibles ;
* pas de rendu “prototype” ;
* pas de placeholders moches ;
* pas de textes du type “placeholder” visibles dans l’app finale ;
* pas de look simple “Material demo”.

---

# DESIGN TOKENS OBLIGATOIRES

Utiliser partout :

```dart
IFColors.black       // background principal
IFColors.panel       // cards
IFColors.panel2      // inputs / secondary cards
IFColors.panel3      // elevated dark surface
IFColors.border      // borders visibles
IFColors.borderSoft  // borders soft
IFColors.red         // accent principal
IFColors.redDark     // dark red
IFColors.redGlow     // glow / danger
IFColors.gold        // PR / trophy
IFColors.green       // positive delta only
IFColors.orange      // streak / fire
IFColors.blue        // AI secondary
IFColors.text        // main text
IFColors.textMuted   // secondary text
IFColors.textFaint   // very secondary text
```

Règles :

* Rouge = action principale.
* Gold = PR/records.
* Green = progression positive uniquement.
* Orange = streak/fire.
* Blue = AI secondaire.
* Aucun accent teal comme couleur principale.

---

# RÈGLES UX

L’app doit être utilisable en salle de sport :

* boutons larges ;
* textes lisibles ;
* logging rapide ;
* maximum 1–2 taps pour logger un set ;
* bottom navigation toujours accessible ;
* pas de menus profonds inutiles ;
* les cards doivent être compactes ;
* les écrans doivent montrer beaucoup d’information utile sans être confus ;
* les données réelles doivent venir de Hive quand possible ;
* si la donnée n’existe pas, afficher un état propre, pas une fausse donnée.

---

# COMMANDES DE VALIDATION GÉNÉRALES

À la fin de chaque phase importante :

```bash
flutter pub get
flutter analyze
flutter test
```

À la fin des phases UI complètes :

```bash
flutter build apk --debug
```

Ne pas ignorer les erreurs.
Ne pas supprimer des tests pour faire passer le build.

---

# PLAN GLOBAL

Le redesign doit être fait en 9 phases :

1. Audit UI + design system premium
2. Home dashboard premium
3. Workout logger premium
4. Rest timer + plate calculator
5. History screen premium
6. Progress overview premium
7. Exercises library premium
8. Programs/Routines premium + AI Coach
9. Polish final + QA + screenshots readiness

Chaque phase a un prompt séparé plus bas.

---

# PHASE 1 — Audit UI + Design System Premium

## Objectif

Créer une base visuelle vraiment professionnelle avant de toucher tous les écrans.

Ne pas refaire les écrans complets dans cette phase.
Seulement améliorer les fondations UI.

## Fichiers à lire

* `lib/src/core/app_theme.dart`
* `lib/src/core/if_text_styles.dart`
* `lib/src/shared/widgets/`
* `lib/src/core/router.dart`
* `pubspec.yaml`

## Travail à faire

### 1. Vérifier le thème

S’assurer que :

* `IFColors` existe ;
* le rouge est la couleur principale ;
* les anciens `forgeElectric`, `forgePanel`, etc. pointent vers la nouvelle palette ;
* les boutons rouges sont bien premium ;
* les cards ont une bordure fine ;
* les inputs sont sombres ;
* les snackbars sont sombres ;
* le fond général est noir profond.

### 2. Améliorer le design system

Créer ou améliorer ces widgets :

```text
lib/src/shared/widgets/forge_card.dart
lib/src/shared/widgets/forge_bottom_nav.dart
lib/src/shared/widgets/forge_shell.dart
lib/src/shared/widgets/forge_primary_button.dart
lib/src/shared/widgets/forge_metric_tile.dart
lib/src/shared/widgets/forge_chip.dart
lib/src/shared/widgets/forge_section_header.dart
lib/src/shared/widgets/forge_empty_state.dart
lib/src/shared/widgets/forge_progress_ring.dart
lib/src/shared/widgets/forge_glass_panel.dart
lib/src/shared/widgets/forge_action_tile.dart
lib/src/shared/widgets/forge_screen_background.dart
```

### 3. Créer `ForgeScreenBackground`

Il doit ajouter :

* fond noir ;
* très léger gradient rouge sombre en haut ;
* pas trop visible ;
* pas de look flashy.

### 4. Créer `ForgeProgressRing`

Utilisé plus tard pour :

* rest timer ;
* recovery ;
* circular stats.

Il doit accepter :

```dart
value
size
strokeWidth
center
color
backgroundColor
```

### 5. Améliorer `ForgeCard`

La card doit avoir :

* radius 14–18 ;
* border `IFColors.borderSoft` ;
* fond `IFColors.panel` ;
* padding configurable ;
* option glow rouge ;
* option selected ;
* option onTap.

### 6. Améliorer Bottom Nav

La bottom navigation doit ressembler à la preview :

* noire ;
* bordure top ;
* icônes compactes ;
* item actif rouge ;
* labels petits ;
* pas d’indicator Material trop gros si ça fait amateur.

Si `NavigationBar` fait trop générique, créer une custom bottom nav avec `Container`, `Row`, `InkWell`.

Items :

```text
Home
History
Exercises
Progress
Programs
```

### 7. Assets folders

Créer si manquants :

```text
assets/branding/
assets/images/athletes/
assets/images/programs/
assets/images/ai/
assets/images/empty_states/
```

Ne pas ajouter d’images lourdes non nécessaires.
Créer uniquement `.gitkeep` si besoin.

## Ne pas faire dans cette phase

* Ne pas redesign Home complet.
* Ne pas redesign Workout complet.
* Ne pas ajouter Firebase.
* Ne pas ajouter RevenueCat.
* Ne pas modifier la logique Hive.

## Validation

Lancer :

```bash
flutter pub get
flutter analyze
flutter test
```

## Commit

```bash
git add .
git commit -m "Polish IronForge design system foundation"
```

## Stop

Après le commit, s’arrêter.

---

# PROMPT À DONNER À CODEX POUR LA PHASE 1

```text
PHASE 1 ONLY.

Lis `IRONFORGE_CODEX_REDESIGN_INSTRUCTIONS.md`, puis ce plan de phases. Travaille uniquement sur la Phase 1 : Audit UI + Design System Premium.

Objectif : améliorer les fondations UI pour que l’app puisse vraiment ressembler à la preview IronForge rouge/noir. Ne redesign pas encore tous les écrans. Crée/améliore les widgets shared premium : ForgeCard, ForgeBottomNav, ForgeShell, ForgePrimaryButton, ForgeMetricTile, ForgeChip, ForgeSectionHeader, ForgeEmptyState, ForgeProgressRing, ForgeGlassPanel, ForgeActionTile, ForgeScreenBackground.

Respecte l’existant : Hive, providers, repositories, routes, tests, package `com.ironforge.app`. N’ajoute pas Firebase ni RevenueCat.

À la fin, lance `flutter pub get`, `flutter analyze`, `flutter test`. Corrige les erreurs. Fais un commit `Polish IronForge design system foundation`. Puis arrête-toi.
```

---

# PHASE 2 — Home Dashboard Premium

## Objectif

Transformer le Home en écran premium proche du premier téléphone de la preview.

Le Home actuel est trop simple.
Il doit devenir un vrai dashboard commercial.

## Fichiers à lire

* `lib/src/features/workout_logger/presentation/home_screen.dart`
* `lib/src/shared/widgets/`
* `lib/src/core/app_theme.dart`
* `lib/src/core/if_text_styles.dart`
* `lib/src/features/workout_logger/data/workout_repository.dart`
* `lib/src/features/progress/domain/progress_stats.dart`
* `lib/src/features/onboarding/data/user_profile_repository.dart`

## Travail à faire

### 1. Header premium

Créer un haut d’écran :

```text
Yo, Iron Titan 💪
Let's crush today.
```

À droite :

* notification icon ;
* ou settings icon ;
* card carrée sombre.

Le header doit être compact et premium.

### 2. Hero streak card

Créer une card comme la preview :

```text
Workout Streak
12 days
🔥🔥🔥🔥🔥
Best: 28 days
```

Mais :

* `12 days` doit venir du calcul réel si possible ;
* si aucune séance : `0 days` ;
* ne pas afficher le mot `placeholder`.

Style :

* fond panel ;
* glow rouge subtil ;
* fire icon orange ;
* texte dense ;
* best streak si calculable, sinon “Best: —”.

### 3. Quote card

Créer une quote card premium :

```text
Discipline is choosing between what you want now and what you want most.
```

À droite :

* silhouette athlete si asset disponible ;
* sinon icône fitness dans cercle rouge sombre.

Aucun placeholder visible.

### 4. Bouton Start Workout

Bouton rouge pleine largeur :

```text
START WORKOUT
```

Avec icône play.
Il doit aller vers `/workout`.

### 5. Today's Plan

Card :

```text
Today's Plan
Push Day
5 Exercises
PPL
```

Si aucune routine réelle :

* afficher une suggestion propre ;
* pas de texte placeholder ;
* CTA vers Programs.

### 6. Metrics compactes

Grid 2x2 ou 3 cards selon écran :

```text
Volume
Workouts
Sets
Best Bench
```

Données réelles depuis Hive/ProgressStats.

### 7. Quick actions

Cards compactes :

```text
Progress
Exercises
Programs
AI Coach
```

Chaque card doit ressembler à un bouton premium.

## Détails visuels

* Padding page : 16.
* Espacement vertical : 10–16.
* Cards radius : 14–18.
* Header hero pas trop grand.
* Il faut voir plusieurs sections sans trop scroller.
* Ne pas faire un écran vide avec juste 4 cards.

## Ne pas faire

* Ne pas afficher `placeholder`.
* Ne pas inventer de calories si pas calculées.
* Ne pas ajouter de backend.

## Validation

```bash
flutter analyze
flutter test
```

Tester visuellement :

```bash
flutter run
```

## Commit

```bash
git add .
git commit -m "Upgrade home dashboard to premium IronForge layout"
```

## Stop

Après le commit, s’arrêter.

---

# PROMPT À DONNER À CODEX POUR LA PHASE 2

```text
PHASE 2 ONLY.

Travaille uniquement sur le Home Dashboard Premium. Le Home actuel reste trop simple par rapport à la preview. Transforme `home_screen.dart` en vrai dashboard premium IronForge : header “Yo, Iron Titan / Let’s crush today”, streak card, quote card, gros bouton START WORKOUT, Today’s Plan, metrics réelles depuis Hive/ProgressStats, quick actions.

Utilise uniquement les composants du design system déjà créés. Ne touche pas au workout logger, progress, exercises ou routines sauf si un import est nécessaire. Aucun texte “placeholder” visible dans l’app. Pas de Firebase, pas de RevenueCat.

À la fin, lance `flutter analyze` et `flutter test`. Corrige les erreurs. Fais un commit `Upgrade home dashboard to premium IronForge layout`. Puis arrête-toi.
```

---

# PHASE 3 — Workout Logger Premium

## Objectif

Transformer le workout logger en écran professionnel proche du téléphone “Bench Press” de la preview.

C’est l’écran le plus important de l’app.

## Fichiers à lire

* `lib/src/features/workout_logger/presentation/workout_logger_screen.dart`
* `lib/src/features/workout_logger/presentation/workout_controller.dart`
* `lib/src/features/workout_logger/domain/workout.dart`
* `lib/src/features/workout_logger/domain/workout_math.dart`
* `lib/src/features/exercises/data/exercise_repository.dart`
* `lib/src/shared/widgets/`

## Règle absolue

Ne pas casser la logique actuelle :

* add exercise ;
* add set ;
* same as last ;
* smart set ;
* kg/lbs ;
* notes ;
* edit set ;
* delete set ;
* rest timer ;
* PR detection ;
* haptic ;
* sound ;
* finish workout.

## Travail à faire

### 1. Header workout

Créer un header dense :

```text
Live Workout
ou
Bench Press
```

Avec :

* back button ;
* menu three dots ;
* timer global si disponible ;
* nombre de sets ;
* volume total.

### 2. Exercise picker premium

Le dropdown actuel fait trop simple.

Le remplacer ou l’améliorer :

* champ sombre ;
* icône search ;
* bouton add ;
* bottom sheet search si possible ;
* liste rapide d’exercices.

Objectif : ajouter un exercice rapidement sans look prototype.

### 3. Exercise card premium

Chaque exercice doit ressembler à la preview :

* nom exercice ;
* chips :

  * équipement ;
  * muscle ;
  * type ;
* section sets ;
* section notes compacte ;
* actions.

### 4. Table sets

Afficher les sets sous forme dense :

```text
SET   KG   REPS   RPE   ✓
1     100  8      8     ✓
2     100  8      9     ✓
3     102.5 6     9     ○
```

Style :

* rows sombres ;
* border fine ;
* check rouge ;
* PR = bordure gold + trophy.

### 5. Inputs rapides

La zone de logging doit être compacte :

```text
Weight | Reps | RPE
```

Puis boutons :

```text
Same as last
Smart +
LOG SET
```

`LOG SET` rouge.

### 6. Actions secondaires

Ajouter :

```text
+ Add Set
Plate Calculator
Rest Timer
```

Ces actions doivent ouvrir les écrans/bottom sheets si disponibles.

### 7. PR Celebration

Quand PR détecté :

* haptic lourd ;
* dialog premium ;
* gold trophy ;
* texte `PR FORGED`;
* ne pas se répéter au rebuild.

### 8. Finish Workout

Bouton clair :

```text
FINISH
```

Visible dans header ou bottom sticky area.

Après finish :

* sauvegarde Hive ;
* snackbar premium ;
* retour home ou summary simple.

## Détails visuels

* Dense comme preview.
* Ne pas mettre de cards énormes.
* Boutons larges mais compacts.
* Inputs faciles à toucher.
* Beaucoup d’info utile visible.
* Pas de composant Material brut.

## Validation

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Commit

```bash
git add .
git commit -m "Upgrade workout logger to premium set tracking UI"
```

## Stop

Après le commit, s’arrêter.

---

# PROMPT À DONNER À CODEX POUR LA PHASE 3

```text
PHASE 3 ONLY.

Travaille uniquement sur le Workout Logger Premium. C’est l’écran le plus important. Redesign `workout_logger_screen.dart` pour qu’il ressemble au téléphone “Bench Press” de la preview : header dense, chips équipement/muscle/type, table de sets compacte, inputs weight/reps/RPE, boutons Same as last, Smart +, LOG SET rouge, Plate Calculator, Rest Timer, PR celebration, Finish clair.

Ne casse aucune logique existante : Hive, workoutControllerProvider, addSet, addSameAsLastSet, addSmartSet, updateSet, deleteSet, notes, kg/lbs, PR detection, haptics, sound, finish workout.

Ne touche pas aux autres écrans sauf si nécessaire pour import/shared widgets. Pas de Firebase, pas de RevenueCat.

À la fin, lance `flutter analyze`, `flutter test`, `flutter build apk --debug`. Corrige les erreurs. Fais un commit `Upgrade workout logger to premium set tracking UI`. Puis arrête-toi.
```

---

# PHASE 4 — Rest Timer + Plate Calculator

## Objectif

Créer deux écrans premium proches de la preview :

1. Rest Timer circulaire
2. Plate Calculator visuel

## Fichiers à lire

* `lib/src/features/workout_logger/presentation/rest_timer_screen.dart`
* `lib/src/features/workout_logger/presentation/plate_calculator_screen.dart`
* `lib/src/features/workout_logger/domain/workout_math.dart`
* `lib/src/core/router.dart`
* `lib/src/shared/widgets/`

## Travail Rest Timer

Créer un écran comme la preview :

```text
Rest Timer
RESTING
1:42
UP NEXT
Bench Press
Set 3 of 4
```

UI :

* grand cercle rouge ;
* progress ring ;
* bouton pause/play rouge ;
* bouton `-15s` ;
* bouton `+15s` ;
* rows :

  * Vibration ON
  * Sound BEEP

Le timer peut rester local.
Pas besoin de background notifications.

## Travail Plate Calculator

Créer un écran comme la preview :

```text
Plate Calculator
KG | LBS
102.5 kg
Total Weight
```

UI :

* toggle kg/lbs ;
* poids total très visible ;
* visual barbell avec disques colorés ;
* liste de plates ;
* total en rouge.

Exemple :

```text
20 kg     2 plates
15 kg     2 plates
10 kg     2 plates
2.5 kg    2 plates
Bar       20 kg
TOTAL     102.5 kg
```

Si aucune image de barre :

* utiliser des `Container` rectangles/cylindres ;
* couleurs plates :

  * red
  * blue
  * yellow
  * green
  * grey.

## Connexion avec Workout Logger

Depuis Workout Logger :

* bouton Rest Timer ouvre `/rest-timer` ou bottom sheet ;
* bouton Plate Calculator ouvre `/plate-calculator` ou bottom sheet.

## Validation

```bash
flutter analyze
flutter test
```

## Commit

```bash
git add .
git commit -m "Add premium rest timer and plate calculator screens"
```

## Stop

Après le commit, s’arrêter.

---

# PROMPT À DONNER À CODEX POUR LA PHASE 4

```text
PHASE 4 ONLY.

Travaille uniquement sur Rest Timer + Plate Calculator. Crée/améliore `rest_timer_screen.dart` et `plate_calculator_screen.dart` pour qu’ils ressemblent à la preview : grand cercle rouge pour le timer, -15s/pause/+15s, vibration/sound rows ; calculateur de plaques avec toggle KG/LBS, poids total grand, visual barbell, liste de plates, total rouge.

Branche les boutons depuis le workout logger si nécessaire, mais ne redesign pas le workout logger complet. Pas de notifications background, pas de permissions sensibles.

À la fin, lance `flutter analyze` et `flutter test`. Corrige les erreurs. Fais un commit `Add premium rest timer and plate calculator screens`. Puis arrête-toi.
```

---

# PHASE 5 — History Screen Premium

## Objectif

Créer ou améliorer un écran History proche de la preview.

## Fichiers à lire

* `lib/src/features/workout_logger/presentation/history_screen.dart`
* `lib/src/features/workout_logger/data/workout_repository.dart`
* `lib/src/features/workout_logger/domain/workout.dart`
* `lib/src/core/router.dart`
* `lib/src/shared/widgets/`

## Travail à faire

### 1. Header

```text
History
```

Avec :

* filter icon ;
* tabs.

### 2. Tabs

```text
All
Workouts
PRs
Notes
```

Le filtrage peut être simple.
Mais l’UI doit être présente.

### 3. Liste par date

Chaque groupe :

```text
May 18, 2024
Push Day
```

Card workout :

* nom séance ;
* date ;
* volume ;
* nombre exercices ;
* nombre sets ;
* duration si disponible.

### 4. Exercise rows

Sous chaque séance :

```text
Bench Press        102.5 kg
Incline Dumbbell   40 kg
Overhead Press     60 kg
```

Si pas de meilleur poids, afficher :

```text
Bodyweight
```

ou `—`.

### 5. Empty state

Si aucune séance :

```text
No workouts yet.
Start your first session and forge your baseline.
START WORKOUT
```

## Validation

```bash
flutter analyze
flutter test
```

## Commit

```bash
git add .
git commit -m "Build premium workout history screen"
```

## Stop

Après le commit, s’arrêter.

---

# PROMPT À DONNER À CODEX POUR LA PHASE 5

```text
PHASE 5 ONLY.

Travaille uniquement sur l’écran History. Crée/améliore `history_screen.dart` pour qu’il ressemble à la preview : header, filtre, tabs All/Workouts/PRs/Notes, groupes par date, workout cards compactes, rows d’exercices avec meilleur poids, empty state premium. Utilise `workoutHistoryProvider` et les données Hive réelles.

Ne touche pas au workout logger, Home, Progress ou Exercises sauf import nécessaire. Pas de Firebase, pas de RevenueCat.

À la fin, lance `flutter analyze` et `flutter test`. Corrige les erreurs. Fais un commit `Build premium workout history screen`. Puis arrête-toi.
```

---

# PHASE 6 — Progress Overview Premium

## Objectif

Transformer Progress en écran premium proche de la preview.

## Fichiers à lire

* `lib/src/features/progress/presentation/progress_screen.dart`
* `lib/src/features/progress/domain/progress_stats.dart`
* `lib/src/features/workout_logger/data/workout_repository.dart`
* `lib/src/shared/widgets/`

## Travail à faire

### 1. Header

```text
Progress Overview
```

### 2. Period tabs

```text
7D
4W
3M
1Y
ALL
```

Le filtre doit fonctionner au moins basiquement.
Si trop complexe, commencer par changer l’affichage selon période avec sessions filtrées par date.

### 3. Main strength card

Créer une card :

```text
Bench Press
1RM Estimate
122.5 kg
+5.2 kg from last month
```

Données :

* utiliser `ProgressStats.bestE1rmFor('bench_press')` si disponible ;
* delta seulement si calculable ;
* sinon afficher `—`.

### 4. Chart rouge

Utiliser `fl_chart`.

Style :

* fond panel ;
* ligne rouge ;
* dots rouges ;
* area rouge très transparente ;
* axes discrets ;
* pas de chart générique bleu/vert.

### 5. Stat cards

```text
Total Volume
Total Workouts
PRs
Completed Sets
```

### 6. Empty state

Si aucune donnée :

```text
No progress yet.
Save workouts to build your strength curve.
```

## Validation

```bash
flutter analyze
flutter test
```

## Commit

```bash
git add .
git commit -m "Upgrade progress overview with premium analytics UI"
```

## Stop

Après le commit, s’arrêter.

---

# PROMPT À DONNER À CODEX POUR LA PHASE 6

```text
PHASE 6 ONLY.

Travaille uniquement sur Progress Overview. Redesign `progress_screen.dart` pour qu’il ressemble à la preview : tabs 7D/4W/3M/1Y/ALL, main card Bench Press 1RM Estimate, chart rouge fl_chart, stat cards Total Volume/Workouts/PRs/Sets, empty state premium. Utilise les données Hive/ProgressStats réelles. Ne montre pas de fausses données.

Ne touche pas aux autres écrans sauf shared widgets/imports nécessaires. À la fin, lance `flutter analyze` et `flutter test`. Corrige les erreurs. Fais un commit `Upgrade progress overview with premium analytics UI`. Puis arrête-toi.
```

---

# PHASE 7 — Exercises Library Premium

## Objectif

Transformer Exercise Library en écran proche de la preview.

## Fichiers à lire

* `lib/src/features/exercises/presentation/exercise_library_screen.dart`
* `lib/src/features/exercises/data/exercise_repository.dart`
* `lib/src/features/exercises/domain/exercise.dart`
* `lib/src/shared/widgets/`

## Travail à faire

### 1. Header

```text
Exercises
```

Avec :

* search icon ;
* filter icon.

### 2. Search field

Champ :

```text
Search exercises...
```

Style sombre premium.

### 3. Filter chips

```text
All
Chest
Back
Legs
Shoulders
Favorites
Custom
```

Les filtres doivent garder la logique existante.

### 4. Liste exercices

Chaque row :

* icône équipement/muscle ;
* nom exercice ;
* équipement ;
* muscle ;
* star favorite ;
* badge custom si exercice custom.

Style :

* rows compactes ;
* border fine ;
* star gold si favorite ;
* pas de ListTile brut trop simple.

### 5. Equipment grid

Section :

```text
Equipment
Barbell
Dumbbell
Machine
Cable
Bodyweight
```

Chaque item doit être une mini-card.

### 6. Custom exercise

Garder :

* création ;
* modification ;
* suppression ;
* persistance Hive.

Mais améliorer visuellement les dialogs/sheets.

## Validation

```bash
flutter analyze
flutter test
```

## Commit

```bash
git add .
git commit -m "Upgrade exercise library to premium searchable UI"
```

## Stop

Après le commit, s’arrêter.

---

# PROMPT À DONNER À CODEX POUR LA PHASE 7

```text
PHASE 7 ONLY.

Travaille uniquement sur Exercise Library. Redesign `exercise_library_screen.dart` pour qu’il ressemble à la preview : search field sombre, filter icon, chips All/Chest/Back/Legs/Shoulders/Favorites/Custom, rows compactes avec icône, équipement, muscle, favorite star, equipment grid. Garde toute la logique existante : favoris Hive, exercices custom, recherche, création, modification, suppression.

Ne touche pas aux autres écrans sauf import/shared widgets nécessaires. À la fin, lance `flutter analyze` et `flutter test`. Corrige les erreurs. Fais un commit `Upgrade exercise library to premium searchable UI`. Puis arrête-toi.
```

---

# PHASE 8 — Programs/Routines Premium + AI Coach

## Objectif

Transformer Routines en Programs premium et créer AI Coach placeholder.

## Fichiers à lire

* `lib/src/features/routines/presentation/routines_screen.dart`
* `lib/src/features/routines/data/`
* `lib/src/features/routines/domain/`
* `lib/src/features/ai_coach/presentation/ai_coach_screen.dart`
* `lib/src/core/router.dart`
* `lib/src/shared/widgets/`

## Partie A — Programs/Routines

### Objectif

L’écran doit ressembler à la preview “Programs”.

### UI

Header :

```text
Programs
```

Tabs :

```text
My Programs
Explore
```

Cards Explore :

```text
PPL 6 Day Split
Intermediate • 6 days/week
Popular

5x5 Strength
Beginner • 3 days/week

Upper / Lower
Intermediate • 4 days/week

Bro Split
Advanced • 5 days/week
```

Chaque card :

* image ou gradient ;
* titre ;
* niveau/fréquence ;
* star ;
* badge ;
* chevron.

### Données

Garder routines Hive :

* création ;
* édition ;
* suppression ;
* progression rule.

Ne pas remplacer les routines utilisateur par une liste statique uniquement.

## Partie B — AI Coach

Créer/améliorer :

`lib/src/features/ai_coach/presentation/ai_coach_screen.dart`

UI cible :

```text
AI Coach
```

Insight card :

```text
Your bench press has been stuck for 3 weeks.
Consider a deload or variation.
VIEW RECOMMENDATION
```

Recovery card :

```text
82%
Good to go
Sleep       Coming soon
HRV         Coming soon
```

Volume analysis :

```text
High volume on legs.
Consider reducing leg volume by 15%.
```

Mini chart rouge.

Important :

* Ne pas prétendre avoir des données capteurs réelles.
* Utiliser `Coming soon`.
* Pas de permissions.
* Pas d’API IA.

## Validation

```bash
flutter analyze
flutter test
```

## Commit

```bash
git add .
git commit -m "Upgrade programs and AI coach premium screens"
```

## Stop

Après le commit, s’arrêter.

---

# PROMPT À DONNER À CODEX POUR LA PHASE 8

```text
PHASE 8 ONLY.

Travaille uniquement sur Programs/Routines + AI Coach. Redesign `routines_screen.dart` en écran Programs premium avec tabs My Programs/Explore, cards PPL/5x5/Upper Lower/Bro Split, gradients/images, badges, favoris, tout en gardant les routines Hive créables/modifiables/supprimables. Ensuite crée/améliore `ai_coach_screen.dart` comme placeholder premium : insight card, recovery Coming soon, volume analysis mini chart rouge.

Ne pas ajouter Firebase, RevenueCat, API IA, permissions capteurs. À la fin, lance `flutter analyze` et `flutter test`. Corrige les erreurs. Fais un commit `Upgrade programs and AI coach premium screens`. Puis arrête-toi.
```

---

# PHASE 9 — Polish Final + QA + Preview Matching

## Objectif

Dernière passe pour rendre l’app cohérente et proche de la preview.

Cette phase est uniquement du polish, pas une réécriture.

## Fichiers à vérifier

Tous les écrans :

```text
Home
Workout Logger
Rest Timer
Plate Calculator
History
Progress
Exercises
Programs
AI Coach
Onboarding
Premium
```

## Travail à faire

### 1. Cohérence visuelle

Vérifier partout :

* même fond noir ;
* mêmes cards ;
* mêmes radius ;
* mêmes borders ;
* mêmes boutons ;
* mêmes text styles ;
* même bottom nav ;
* pas de composant brut Flutter qui fait prototype.

### 2. Supprimer textes non pro

Supprimer ou remplacer :

```text
placeholder
TODO
Coming soon
```

Exception : `Coming soon` est autorisé uniquement sur Premium / AI sensor data.

### 3. Espacements

Uniformiser :

```text
page padding : 16
card padding : 12–16
section spacing : 14–20
row spacing : 8–12
radius : 14–18
border : 1px
```

### 4. Responsive

Tester sur tailles :

* petit Android ;
* standard 390x844 ;
* grand téléphone.

Pas d’overflow.

### 5. Empty states

Tous les écrans doivent avoir un état vide propre :

* pas d’écran blanc ;
* pas de liste vide sans message ;
* CTA quand utile.

### 6. App icon / branding

Si possible :

* vérifier assets branding ;
* ne pas casser pubspec ;
* ne pas ajouter de gros fichiers inutiles.

### 7. QA fonctionnelle

Tester manuellement :

* onboarding ;
* ajouter exercice custom ;
* favorite exercise ;
* start workout ;
* add exercise ;
* log set ;
* same as last ;
* smart set ;
* edit/delete set ;
* finish workout ;
* voir history ;
* voir progress ;
* créer routine ;
* modifier routine.

## Validation finale obligatoire

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Commit

```bash
git add .
git commit -m "Final polish for premium IronForge preview match"
```

## Stop

Après le commit, s’arrêter.

---

# PROMPT À DONNER À CODEX POUR LA PHASE 9

```text
PHASE 9 ONLY.

Fais uniquement le polish final et la QA visuelle. Compare tous les écrans à la preview IronForge rouge/noir. Uniformise cards, spacing, radius, borders, typography, bottom nav, empty states. Supprime les textes non professionnels comme “placeholder” sauf Coming soon pour Premium/AI sensor data. Vérifie qu’il n’y a pas d’overflow. Ne réécris pas l’app. Ne change pas la logique Hive.

Teste manuellement les flows principaux. À la fin, lance `flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`. Corrige toutes les erreurs. Fais un commit `Final polish for premium IronForge preview match`. Puis arrête-toi.
```

---

# ORDRE EXACT À UTILISER AVEC CODEX

Ne donne pas tout en une seule demande.

Utilise ces prompts un par un :

1. Donner le prompt Phase 1.
2. Attendre qu’il termine et commit.
3. Vérifier visuellement.
4. Donner le prompt Phase 2.
5. Attendre qu’il termine et commit.
6. Vérifier visuellement.
7. Continuer jusqu’à Phase 9.

Si une phase donne un mauvais résultat, ne passe pas à la suivante.
Demander une correction ciblée de la même phase.

---

# PROMPT DE CORRECTION SI LE RÉSULTAT EST TROP SIMPLE

Utiliser ce prompt si Codex fait un écran trop basique :

```text
Le résultat est encore trop simple et trop proche d’un prototype Flutter. Ne passe pas à la phase suivante.

Reprends uniquement l’écran de cette phase et rapproche-le beaucoup plus de la preview IronForge : plus dense, plus premium, cards plus compactes, borders fines, rouge plus présent, meilleur header, meilleur spacing, aucun composant Material brut visible, aucun texte placeholder, meilleure hiérarchie visuelle.

Ne modifie pas la logique. Ne touche pas aux autres écrans. Relance `flutter analyze` et `flutter test`, corrige les erreurs, puis commit une correction avec un message clair.
```

---

# PROMPT DE CORRECTION SI CODEX CASSE LA LOGIQUE

Utiliser ce prompt si une fonctionnalité existante casse :

```text
Tu as cassé une logique existante. Ne continue pas le redesign.

Répare uniquement la régression. Garde l’UI déjà faite si possible, mais restaure la fonctionnalité : Hive, repository, provider, workout logging, routines, exercices custom, favoris, onboarding ou history selon le problème.

Ne supprime aucun test. Ajoute un test si nécessaire. Relance `flutter analyze` et `flutter test`. Commit uniquement le fix.
```

---

# PROMPT DE CORRECTION SI CODEX FAIT TROP DE CHOSES

Utiliser ce prompt si Codex dépasse la phase :

```text
Tu as dépassé le périmètre de la phase. Reviens au scope demandé.

Annule ou limite les changements qui ne concernent pas cette phase, sauf s’ils sont strictement nécessaires pour compiler. Le projet doit avancer étape par étape. Ne commence jamais une phase suivante sans demande explicite.
```

---

# VALIDATION FINALE VISUELLE

L’app finale doit avoir ce niveau :

## Home

Doit montrer :

* branding IronForge ;
* greeting ;
* streak card ;
* quote card ;
* gros bouton START WORKOUT ;
* Today’s Plan ;
* stats cards ;
* quick actions premium.

## Workout Logger

Doit montrer :

* header dense ;
* exercise picker premium ;
* chips equipment/muscle ;
* table de sets ;
* inputs rapides ;
* Same as last ;
* Smart + ;
* Log Set rouge ;
* Plate Calculator ;
* Rest Timer ;
* PR celebration ;
* Finish clair.

## Rest Timer

Doit montrer :

* cercle rouge ;
* temps au centre ;
* -15s ;
* pause/play ;
* +15s ;
* vibration ;
* sound.

## Plate Calculator

Doit montrer :

* kg/lbs toggle ;
* poids total grand ;
* barre visuelle ;
* plates list ;
* total rouge.

## History

Doit montrer :

* tabs ;
* groupes par date ;
* workout cards ;
* exercise rows ;
* empty state premium.

## Progress

Doit montrer :

* period tabs ;
* main 1RM estimate card ;
* chart rouge ;
* stat cards.

## Exercises

Doit montrer :

* search ;
* chips ;
* list rows compactes ;
* favorite stars ;
* equipment grid ;
* custom exercises.

## Programs

Doit montrer :

* My Programs / Explore ;
* program cards premium ;
* routines Hive toujours modifiables.

## AI Coach

Doit montrer :

* insight card ;
* recovery card ;
* volume analysis ;
* coming soon clair pour données capteurs.

---

# DÉFINITION DU RÉSULTAT PROFESSIONNEL

Le résultat est accepté seulement si :

* l’app ne ressemble plus à un prototype ;
* les écrans ressemblent à une vraie app premium ;
* l’app est cohérente écran par écran ;
* l’expérience est rapide ;
* l’identité rouge/noir est forte ;
* aucune logique existante n’est cassée ;
* tous les tests passent ;
* le build debug Android passe.

Fin du plan.

