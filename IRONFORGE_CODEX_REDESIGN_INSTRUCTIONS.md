# IRONFORGE — Instructions complètes pour Codex

Objectif : transformer l’application Flutter IronForge existante en une app premium conforme à la preview rouge/noir fournie par le propriétaire du projet.

Repo : `https://github.com/BELKEDARYOUCEF/IronForge`
Branche : `main`
Package Android : `com.ironforge.app`
Framework : Flutter
Nom app : `IronForge`

Priorité : redesign visuel + expérience utilisateur premium, sans casser la base locale Hive déjà fonctionnelle.

---

## 1. Contexte actuel du projet

Le projet est déjà une base Flutter offline-first fonctionnelle.

Fonctionnalités déjà présentes :

* Hive local storage pour workouts, routines, exercices, profil onboarding.
* Workout logger local.
* Historique réel branché sur Hive.
* Routines modifiables.
* Exercices custom et favoris.
* Onboarding local.
* Graphiques via `fl_chart`.
* Tests et analyse statique déjà passés.
* Package Android final : `com.ironforge.app`.
* Pas de Firebase.
* Pas de RevenueCat.
* Pas de permissions sensibles Android.

Ne pas repartir de zéro.
Ne pas remplacer le projet par un template.
Il faut conserver l’architecture actuelle et améliorer l’UI/UX pour qu’elle ressemble à la preview IronForge rouge/noir.

---

## 2. Objectif final

L’application doit ressembler à une app premium pour serious lifters, powerlifters, bodybuilders et gym bros.

Le résultat doit être proche de la preview envoyée :

* branding IronForge rouge/noir ;
* dashboard premium ;
* workout logger dense et rapide ;
* rest timer circulaire ;
* plate calculator visuel ;
* progress overview avec chart rouge ;
* history screen ;
* exercise library ;
* programs/routines ;
* AI Coach placeholder ;
* bottom navigation persistante ;
* style dark brutalist premium.

L’app doit donner l’impression d’être :

* rapide ;
* agressive ;
* premium ;
* masculine ;
* faite pour progresser en force ;
* addictive à utiliser après chaque set.

---

## 3. Direction artistique cible

Style cible :

* Dark brutalist premium.
* Noir profond.
* Rouge IronForge comme couleur principale.
* Cartes sombres avec bordures fines.
* Typographie forte, compacte, masculine.
* Icônes simples, agressives, orientées gym.
* Beaucoup de contraste.
* Boutons larges, rapides à utiliser en salle.
* Bottom navigation persistante.
* Effets subtils : glow rouge, ombres noires, highlight PR doré.
* Zéro look pastel.
* Zéro look fitness générique.
* Zéro accent teal/vert comme couleur principale.

La preview cible contient ces écrans :

1. Home dashboard
2. Workout logger / Bench Press
3. Rest Timer
4. Plate Calculator
5. Progress Overview
6. History
7. Exercises
8. Programs
9. AI Coach

---

## 4. Palette officielle IronForge

Remplacer l’accent teal actuel par rouge IronForge.

Créer ou modifier :

`lib/src/core/app_theme.dart`

Utiliser cette palette :

```dart
import 'package:flutter/material.dart';

class IFColors {
  static const black = Color(0xFF050505);
  static const black2 = Color(0xFF090909);
  static const panel = Color(0xFF101010);
  static const panel2 = Color(0xFF151515);
  static const panel3 = Color(0xFF1B1B1B);

  static const border = Color(0xFF2A2A2A);
  static const borderSoft = Color(0xFF202020);

  static const red = Color(0xFFE52B2B);
  static const redDark = Color(0xFF9F1717);
  static const redGlow = Color(0xFFFF3B30);

  static const orange = Color(0xFFFF6A00);
  static const gold = Color(0xFFFFC857);
  static const green = Color(0xFF2ED573);
  static const blue = Color(0xFF3B82F6);

  static const text = Color(0xFFF4F4F5);
  static const textMuted = Color(0xFFA1A1AA);
  static const textFaint = Color(0xFF71717A);
}
```

Important :

* Rouge = couleur principale.
* Gold = PR, trophée, record.
* Green = gains positifs, progression, recovery.
* Orange = streak/fire.
* Blue = AI/insight secondaire.
* Ne plus utiliser le teal comme accent principal.
* Si le code actuel utilise `forgeElectric`, remplacer son usage principal par `IFColors.red`.

---

## 5. Thème Flutter final

Mettre à jour `buildIronForgeTheme()` dans `app_theme.dart`.

```dart
ThemeData buildIronForgeTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: IFColors.red,
    brightness: Brightness.dark,
    primary: IFColors.red,
    secondary: IFColors.gold,
    surface: IFColors.panel,
    error: IFColors.redGlow,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: IFColors.black,
    colorScheme: scheme,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: IFColors.black,
      foregroundColor: IFColors.text,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.2,
        color: IFColors.text,
      ),
    ),
    cardTheme: CardThemeData(
      color: IFColors.panel,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: IFColors.borderSoft),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: IFColors.panel2,
      labelStyle: const TextStyle(color: IFColors.textMuted),
      hintStyle: const TextStyle(color: IFColors.textFaint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: IFColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: IFColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: IFColors.red),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: IFColors.red,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: IFColors.text,
        side: const BorderSide(color: IFColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: IFColors.borderSoft,
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: IFColors.panel2,
      contentTextStyle: const TextStyle(
        color: IFColors.text,
        fontWeight: FontWeight.w700,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
```

Si des constantes anciennes existent encore :

```dart
const forgeBlack = ...
const forgePanel = ...
const forgeElectric = ...
```

Ne pas forcément tout supprimer immédiatement si trop risqué, mais les mapper vers la nouvelle palette :

```dart
const forgeBlack = IFColors.black;
const forgePanel = IFColors.panel;
const forgePanelAlt = IFColors.panel2;
const forgeSteel = IFColors.textMuted;
const forgeText = IFColors.text;
const forgeElectric = IFColors.red;
const forgeHot = IFColors.redGlow;
const forgeGold = IFColors.gold;
```

---

## 6. Typographie

Créer :

`lib/src/core/if_text_styles.dart`

Contenu :

```dart
import 'package:flutter/material.dart';
import 'app_theme.dart';

class IFText {
  static const hero = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    height: 1.0,
    letterSpacing: -0.8,
    color: IFColors.text,
  );

  static const h1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
    color: IFColors.text,
  );

  static const h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: IFColors.text,
  );

  static const h3 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w900,
    color: IFColors.text,
  );

  static const cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: IFColors.text,
  );

  static const body = TextStyle(
    fontSize: 14,
    color: IFColors.text,
  );

  static const bodyMuted = TextStyle(
    fontSize: 14,
    color: IFColors.textMuted,
  );

  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.7,
    color: IFColors.textMuted,
  );

  static const micro = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    color: IFColors.textFaint,
  );
}
```

Règles typo :

* Logo/AppBar : `FontWeight.w900`.
* Titres principaux : 24–32 px.
* Cards titles : 16–18 px.
* Body : 13–15 px.
* Labels : uppercase, 10–12 px, `w700`.
* Éviter les textes gris trop clairs.
* Tous les textes doivent rester lisibles sur fond noir.

---

## 7. Logo, branding et app icon

Créer ces dossiers et fichiers :

```text
assets/branding/
  ironforge_logo_full.png
  ironforge_logo_mark.png
  ironforge_logo_mark_red.png
  app_icon_1024.png
  adaptive_icon_foreground.png
  adaptive_icon_background.png
```

Style du logo :

* Monogramme “IF” anguleux.
* Rouge métallique.
* Fond noir.
* Look agressif.
* Forme simple et lisible.
* Pas de style cartoon.
* Pas de couleurs pastel.
* Pas d’haltère obligatoire dans le logo principal.
* Le logo doit être lisible en petit format.

Couleurs logo :

```text
Fond : #050505
Rouge principal : #E52B2B
Rouge ombre : #8E1212
Highlight : #FF4A4A
Texte : #F4F4F5
```

Ajouter plus tard si les assets sont prêts :

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.3

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/branding/app_icon_1024.png"
  adaptive_icon_background: "#050505"
  adaptive_icon_foreground: "assets/branding/adaptive_icon_foreground.png"
```

Commande :

```bash
dart run flutter_launcher_icons
```

Ne jamais committer :

* keystore ;
* `.jks` ;
* `android/key.properties` ;
* `.env` ;
* tokens ;
* secrets.

---

## 8. Icônes nécessaires

Utiliser d’abord Material Icons.
Ne pas bloquer le développement pour des SVG custom.

Navigation principale :

```text
Home       Icons.home_rounded
History    Icons.history_rounded
Exercises  Icons.fitness_center_rounded
Progress   Icons.bar_chart_rounded
Programs   Icons.rocket_launch_rounded
```

Icônes UI :

```text
Start workout       Icons.play_arrow_rounded
Streak              Icons.local_fire_department_rounded
Best/PR             Icons.emoji_events_rounded
Volume              Icons.scale_rounded
Calories            Icons.local_fire_department_outlined
Duration            Icons.timer_rounded
Sets                Icons.check_circle_rounded
Plate calculator    Icons.calculate_rounded
Rest timer          Icons.timer_outlined
Same as last        Icons.replay_rounded
Smart suggestion    Icons.auto_awesome_rounded
Search              Icons.search_rounded
Filter              Icons.tune_rounded
Favorite            Icons.star_rounded
Favorite empty      Icons.star_border_rounded
AI Coach            Icons.psychology_alt_rounded
Recovery            Icons.monitor_heart_rounded
Sleep               Icons.bedtime_rounded
Warning/Insight     Icons.warning_amber_rounded
Settings            Icons.settings_rounded
Notes               Icons.notes_rounded
Delete              Icons.delete_outline_rounded
Edit                Icons.edit_rounded
Add                 Icons.add_rounded
Back                Icons.arrow_back_rounded
More                Icons.more_vert_rounded
```

Equipment icons :

```text
Barbell     Icons.fitness_center_rounded
Dumbbell    Icons.sports_gymnastics_rounded
Machine     Icons.precision_manufacturing_rounded
Cable       Icons.cable_rounded
Bodyweight  Icons.accessibility_new_rounded
```

---

## 9. Images nécessaires

Créer :

```text
assets/images/
  athletes/
  programs/
  onboarding/
  empty_states/
  ai/
```

Images recommandées :

```text
assets/images/athletes/bodybuilder_bw.png
assets/images/athletes/powerlifter_bw.png
assets/images/programs/ppl.png
assets/images/programs/strength_5x5.png
assets/images/programs/upper_lower.png
assets/images/programs/bro_split.png
assets/images/ai/ai_core_hex.png
assets/images/empty_states/no_workouts.png
```

Style images :

* Noir et blanc.
* Contraste fort.
* Légère teinte rouge possible.
* Pas d’images non licenciées de personnes réelles.
* Si aucune image n’est disponible, utiliser gradients + icônes Material.
* Ne pas casser l’app si une image manque.

Créer des placeholders propres en Flutter si les assets ne sont pas encore disponibles.

---

## 10. Mise à jour pubspec.yaml

Ajouter seulement les dépendances utiles.

```yaml
dependencies:
  percent_indicator: ^4.2.3
  confetti: ^0.8.0
```

Optionnel pour launcher icons :

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.3
```

Assets à déclarer :

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/images/athletes/
    - assets/images/programs/
    - assets/images/onboarding/
    - assets/images/empty_states/
    - assets/images/ai/
    - assets/animations/
    - assets/branding/
```

Ne pas ajouter maintenant :

* Firebase ;
* RevenueCat ;
* HealthKit ;
* Google Fit ;
* Strava ;
* camera ;
* location ;
* microphone ;
* contacts.

---

## 11. Design system à créer

Créer ou améliorer :

```text
lib/src/shared/widgets/
  forge_shell.dart
  forge_bottom_nav.dart
  forge_card.dart
  forge_metric_tile.dart
  forge_primary_button.dart
  forge_chip.dart
  forge_section_header.dart
  forge_empty_state.dart
  forge_glow.dart
  pr_celebration.dart
```

### ForgeCard

Créer :

`lib/src/shared/widgets/forge_card.dart`

```dart
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class ForgeCard extends StatelessWidget {
  const ForgeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderColor,
    this.glow = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final bool glow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: BoxDecoration(
        color: IFColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor ?? IFColors.borderSoft),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: IFColors.red.withValues(alpha: 0.22),
                  blurRadius: 22,
                  spreadRadius: -10,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap == null) return content;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: content,
    );
  }
}
```

### ForgeMetricTile

Créer :

`lib/src/shared/widgets/forge_metric_tile.dart`

```dart
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/if_text_styles.dart';
import 'forge_card.dart';

class ForgeMetricTile extends StatelessWidget {
  const ForgeMetricTile({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final String? delta;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ForgeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(
              icon,
              color: iconColor ?? IFColors.red,
              size: 18,
            ),
          if (icon != null) const SizedBox(height: 8),
          Text(label.toUpperCase(), style: IFText.micro),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: IFColors.text,
            ),
          ),
          if (delta != null) ...[
            const SizedBox(height: 4),
            Text(
              delta!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: IFColors.green,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

### ForgeChip

Créer :

`lib/src/shared/widgets/forge_chip.dart`

```dart
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class ForgeChip extends StatelessWidget {
  const ForgeChip({
    super.key,
    required this.label,
    this.selected = false,
    this.icon,
    this.onTap,
  });

  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? IFColors.red : IFColors.panel2;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? IFColors.red : IFColors.panel2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? IFColors.red : IFColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? Colors.white : IFColors.textMuted),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : IFColors.textMuted,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### ForgeSectionHeader

Créer :

`lib/src/shared/widgets/forge_section_header.dart`

```dart
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';

class ForgeSectionHeader extends StatelessWidget {
  const ForgeSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onActionTap,
  });

  final String title;
  final String? action;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: IFColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        if (action != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(action!),
          ),
      ],
    );
  }
}
```

### ForgeEmptyState

Créer :

`lib/src/shared/widgets/forge_empty_state.dart`

```dart
import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../core/if_text_styles.dart';

class ForgeEmptyState extends StatelessWidget {
  const ForgeEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: IFColors.red),
            const SizedBox(height: 16),
            Text(title, style: IFText.h2, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: IFText.bodyMuted, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## 12. Shell et bottom navigation

Le `ForgeShell` actuel est trop simple.
Il doit gérer :

* AppBar premium ;
* body ;
* SafeArea ;
* bottom navigation persistante ;
* route active ;
* bouton retour sur écrans secondaires ;
* fond noir.

Créer :

`lib/src/shared/widgets/forge_bottom_nav.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';

class ForgeBottomNav extends StatelessWidget {
  const ForgeBottomNav({super.key});

  int _indexForPath(String path) {
    if (path.startsWith('/history')) return 1;
    if (path.startsWith('/exercises')) return 2;
    if (path.startsWith('/progress')) return 3;
    if (path.startsWith('/routines')) return 4;
    return 0;
  }

  void _go(BuildContext context, int index) {
    final routes = ['/', '/history', '/exercises', '/progress', '/routines'];
    context.go(routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final selectedIndex = _indexForPath(path);

    return Container(
      decoration: const BoxDecoration(
        color: IFColors.black,
        border: Border(
          top: BorderSide(color: IFColors.borderSoft),
        ),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _go(context, index),
        backgroundColor: IFColors.black,
        indicatorColor: IFColors.red,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_rounded),
            label: 'Exercises',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.rocket_launch_rounded),
            label: 'Programs',
          ),
        ],
      ),
    );
  }
}
```

Mettre à jour :

`lib/src/shared/widgets/forge_shell.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import 'forge_bottom_nav.dart';

class ForgeShell extends StatelessWidget {
  const ForgeShell({
    required this.title,
    required this.child,
    this.actions,
    this.showBottomNav = true,
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final bool showBottomNav;

  bool _canGoBack(String path) {
    return path != '/' &&
        path != '/history' &&
        path != '/exercises' &&
        path != '/progress' &&
        path != '/routines';
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;

    return Scaffold(
      backgroundColor: IFColors.black,
      appBar: AppBar(
        title: Text(title),
        leading: _canGoBack(path)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.go('/'),
              )
            : null,
        actions: actions,
      ),
      body: SafeArea(
        bottom: false,
        child: child,
      ),
      bottomNavigationBar: showBottomNav ? const ForgeBottomNav() : null,
    );
  }
}
```

---

## 13. Router

Mettre à jour :

`lib/src/core/router.dart`

Routes attendues :

```dart
import 'package:go_router/go_router.dart';

import '../features/ai_coach/presentation/ai_coach_screen.dart';
import '../features/exercises/presentation/exercise_library_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/premium/presentation/premium_screen.dart';
import '../features/progress/presentation/progress_screen.dart';
import '../features/routines/presentation/routines_screen.dart';
import '../features/workout_logger/presentation/history_screen.dart';
import '../features/workout_logger/presentation/home_screen.dart';
import '../features/workout_logger/presentation/plate_calculator_screen.dart';
import '../features/workout_logger/presentation/rest_timer_screen.dart';
import '../features/workout_logger/presentation/workout_logger_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/workout', builder: (_, __) => const WorkoutLoggerScreen()),
    GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
    GoRoute(path: '/progress', builder: (_, __) => const ProgressScreen()),
    GoRoute(path: '/exercises', builder: (_, __) => const ExerciseLibraryScreen()),
    GoRoute(path: '/routines', builder: (_, __) => const RoutinesScreen()),
    GoRoute(path: '/premium', builder: (_, __) => const PremiumScreen()),
    GoRoute(path: '/ai-coach', builder: (_, __) => const AiCoachScreen()),
    GoRoute(path: '/rest-timer', builder: (_, __) => const RestTimerScreen()),
    GoRoute(path: '/plate-calculator', builder: (_, __) => const PlateCalculatorScreen()),
  ],
);
```

Si certains imports cassent parce que les fichiers n’existent pas encore, créer les fichiers correspondants.

---

## 14. Home Dashboard cible

Le Home actuel est fonctionnel mais trop simple.
Il doit ressembler au premier téléphone de la preview.

Fichier à modifier :

`lib/src/features/workout_logger/presentation/home_screen.dart`

Contenu cible :

* Header :

  * `Yo, Iron Titan 💪`
  * `Let's crush today.`
  * notification icon
* Streak card :

  * `Workout Streak`
  * nombre de jours
  * fire emojis
  * `Best: 28 days` ou valeur calculée si disponible
* Quote card :

  * citation courte agressive
  * silhouette optionnelle
* Gros bouton rouge :

  * `START WORKOUT`
* Today’s Plan :

  * nom routine ou placeholder
  * nombre d’exercices
  * badge programme
* Stat grid :

  * Volume
  * Workouts
  * Sets
  * Best Bench ou Best E1RM

Ne pas inventer de données trompeuses :

* Si pas d’historique, afficher `0`.
* Si pas de durée dans le modèle, ne pas afficher une vraie duration.
* Si pas de calories, ne pas afficher de calories réelles.
* Les placeholders doivent être clairs.

Structure UI recommandée :

```text
ListView
  Header row
  Hero title
  Streak card
  Quote card
  Start Workout button
  Today's Plan section
  Metrics grid
  Quick actions
```

Quick actions :

```text
Progress
Exercises
Programs
AI Coach
```

Le bouton START WORKOUT doit aller vers `/workout`.

---

## 15. Workout Logger cible

Le workout logger actuel contient déjà beaucoup de logique.
Ne pas supprimer cette logique.

Fichier principal :

`lib/src/features/workout_logger/presentation/workout_logger_screen.dart`

Garder :

* `workoutControllerProvider`
* `addExercise`
* `addSameAsLastSet`
* `addSmartSet`
* `addSet`
* `updateSet`
* `deleteSet`
* `updateExerciseNotes`
* PR detection
* haptic feedback
* sound feedback
* kg/lbs
* rest timer local
* plate calculator logic

Améliorer le rendu pour viser la preview “Bench Press”.

### Header

Afficher :

```text
Live Workout
ou nom de l’exercice principal
```

Sous le titre, afficher des chips :

```text
Barbell
Chest
Compound
```

Si l’exercice n’a pas ces infos, utiliser les infos disponibles dans le modèle Exercise.

### Exercise picker

Remplacer le dropdown brut par :

* search field ou bottom sheet ;
* bouton `+ Add Exercise` ;
* liste rapide d’exercices ;
* style sombre.

Si trop long, garder DropdownButtonFormField mais le rendre visuellement premium.

### Exercise Card

Chaque exercice doit afficher :

* nom exercice ;
* rest timer ;
* notes ;
* sets existants ;
* boutons Same last / Smart + / Log ;
* Plate Calculator.

### Working Sets

Afficher une table compacte :

```text
SET | KG/LBS | REPS | RPE | DONE
1   | 100    | 8    | 8   | check
2   | 100    | 8    | 9   | check
3   | 102.5  | 6    | 9   | circle
```

Les PR doivent avoir :

* bordure gold ;
* trophy icon ;
* texte `PR`.

### Actions

Boutons :

```text
SAME AS LAST TIME
SMART +
LOG SET
+ ADD SET
PLATE CALCULATOR
```

`LOG SET` doit être rouge.

### Rest Timer compact

En bas de chaque exercise card ou dans un sticky area :

```text
REST TIMER
2:30
circular progress
pause button
```

### PR Feedback

Quand `controller.isPr(...)` retourne true au moment du log :

* haptic lourd ;
* dialog ou snackbar ;
* texte : `PR FORGED`;
* icône trophée gold ;
* message : `New estimated max. Keep pushing.`

Ne pas afficher un dialog PR sur chaque rebuild.

---

## 16. Rest Timer plein écran

Créer :

`lib/src/features/workout_logger/presentation/rest_timer_screen.dart`

Design cible :

* Fond noir.
* Titre `Rest Timer`.
* Grand cercle rouge.
* Texte :

  * `RESTING`
  * `1:42`
  * `UP NEXT`
  * `Bench Press`
  * `Set 3 of 4`
* Boutons :

  * `-15s`
  * pause/play rouge
  * `+15s`
* Settings :

  * vibration on/off
  * sound beep/chime/off

Implémentation simple acceptée :

* StatefulWidget local.
* Timer Dart.
* CircularProgressIndicator custom.
* Pas besoin de notification background pour cette phase.

---

## 17. Plate Calculator plein écran

Créer :

`lib/src/features/workout_logger/presentation/plate_calculator_screen.dart`

Design cible :

* Toggle KG/LBS.
* Total weight grand :

  * `102.5 kg`
* Visuel barre simplifié avec disques.
* Liste plates :

  * `20 kg — 2 plates`
  * `15 kg — 2 plates`
  * `10 kg — 2 plates`
  * `2.5 kg — 2 plates`
  * `Bar — 20 kg`
* Total en rouge.

Si aucun dessin complexe :

* Utiliser Row + Containers colorés pour simuler les plates.
* Ne pas ajouter d’asset obligatoire.

Le bouton depuis Workout Logger doit ouvrir cet écran ou un bottom sheet.

---

## 18. History Screen

Créer :

`lib/src/features/workout_logger/presentation/history_screen.dart`

Route :

```text
/history
```

Design cible :

* AppBar `History`
* Icône filtre
* Tabs :

  * All
  * Workouts
  * PRs
  * Notes
* Liste par date :

  * `May 18, 2024`
  * `Push Day`
  * duration si disponible
  * volume
  * exercises
* Chaque exercice en ligne :

  * nom
  * nombre de sets
  * meilleur poids ou bodyweight
  * chevron

Utiliser :

```dart
workoutHistoryProvider
```

État vide :

```text
No workouts yet.
Start your first session and forge your baseline.
```

Bouton :

```text
START WORKOUT
```

---

## 19. Progress Overview cible

Fichier :

`lib/src/features/progress/presentation/progress_screen.dart`

L’écran actuel est fonctionnel mais minimal.
Le rendre proche de la preview.

À ajouter :

* Tabs :

  * `7D`
  * `4W`
  * `3M`
  * `1Y`
  * `ALL`
* Metric principale :

  * `Bench Press`
  * `1RM Estimate`
  * `122.5 kg` ou valeur réelle si disponible
  * delta si calculable
* Chart rouge via `fl_chart`.
* Cards :

  * Total Volume
  * Total Workouts
  * PRs
  * Completed Sets

Garder :

* `ProgressStats`
* `workoutHistoryProvider`
* `fl_chart`

Ne pas afficher de fausses progressions si elles ne sont pas calculées.

---

## 20. Exercise Library cible

Fichier :

`lib/src/features/exercises/presentation/exercise_library_screen.dart`

Doit ressembler à la preview.

À faire :

* Search field sombre.
* Filter icon.
* Chips :

  * All
  * Chest
  * Back
  * Legs
  * Shoulders
* Liste exercices :

  * icône muscle/equipment
  * nom
  * équipement
  * star favorite
* Section équipement :

  * Barbell
  * Dumbbell
  * Machine
  * Cable
  * Bodyweight

Garder la logique actuelle :

* favoris persistants ;
* exercices custom persistants ;
* recherche par nom ;
* recherche par muscle ;
* recherche par equipment ;
* création exercice ;
* modification exercice custom ;
* suppression exercice custom.

---

## 21. Programs / Routines Screen

Fichier :

`lib/src/features/routines/presentation/routines_screen.dart`

Les routines existent déjà.
Ne pas supprimer le repository Hive.

Transformer visuellement l’écran en `Programs`.

Design cible :

* Titre `Programs`.
* Tabs :

  * `My Programs`
  * `Explore`
* Cards :

  * PPL 6 Day Split
  * 5x5 Strength
  * Upper / Lower
  * Bro Split
* Chaque card :

  * image/silhouette ou gradient ;
  * nom ;
  * niveau + fréquence ;
  * favori ;
  * progression rule si disponible.

Mes routines utilisateur doivent rester :

* créables ;
* modifiables ;
* supprimables ;
* persistantes via Hive.

Si aucun asset image disponible :

* utiliser gradient noir/rouge ;
* icône Material ;
* badge niveau/fréquence.

---

## 22. AI Coach placeholder premium

Créer :

`lib/src/features/ai_coach/presentation/ai_coach_screen.dart`

Route :

```text
/ai-coach
```

Design cible :

* Header `AI Coach`
* Insight card :

  * `Your bench press has been stuck for 3 weeks. Consider a deload or variation.`
  * Button `VIEW RECOMMENDATION`
* Recovery card :

  * `82%`
  * `Good to go`
  * sleep placeholder
  * HRV placeholder
* Volume analysis :

  * mini bar chart rouge
  * `High volume on legs. Consider reducing leg volume by 15%.`

Important :

* Marquer clairement `Coming soon` pour HRV/sleep si pas de data réelle.
* Ne pas prétendre lire des capteurs réels.
* Ne pas ajouter permissions health/body sensors.
* Ne pas ajouter API IA réelle maintenant.

---

## 23. Onboarding

Fichier :

`lib/src/features/onboarding/presentation/onboarding_screen.dart`

Garder l’onboarding existant mais améliorer le style.

Champs attendus :

* Goal :

  * Strength
  * Hypertrophy
  * Powerbuilding
  * Fat Loss
* Level :

  * Beginner
  * Intermediate
  * Advanced
* Units :

  * kg
  * lbs
* Frequency :

  * 3 days/week
  * 4 days/week
  * 5 days/week
  * 6 days/week
* Training type :

  * PPL
  * Upper/Lower
  * Full Body
  * Bro Split

Style :

* Cards sélectionnables.
* Sélection rouge.
* Fond noir.
* Gros bouton `FINISH SETUP`.
* Possibilité de revenir modifier depuis Home.

---

## 24. Premium Screen

Fichier :

`lib/src/features/premium/presentation/premium_screen.dart`

Garder comme placeholder.
Ne pas ajouter RevenueCat maintenant.

Style :

* Titre `IronForge Pro`
* Cards features :

  * Cloud Sync
  * Advanced Analytics
  * AI Coach
  * Progress Photos
  * CSV Export
  * Wearables
* Badge `Coming soon`
* Bouton désactivé ou `Join waitlist` local sans backend.

Important :

* Pas d’achat réel.
* Pas de RevenueCat.
* Pas de promesse mensongère si non implémenté.

---

## 25. PR Celebration

Créer :

`lib/src/shared/widgets/pr_celebration.dart`

Objectif :

* feedback premium quand PR détecté ;
* haptic lourd ;
* dialog court ;
* option confetti si dépendance ajoutée.

Contenu dialog :

```text
PR FORGED
New estimated max unlocked.
Keep lifting.
```

Style :

* fond noir/panel ;
* bordure gold ;
* trophy icon gold ;
* bouton rouge.

Ne pas déclencher sur rebuild.
Déclencher uniquement après action utilisateur `Log`.

---

## 26. Rest timer feedback

L’app actuelle a déjà haptic/sound.
Conserver.

Améliorer :

* vibration à fin de repos ;
* son léger ;
* bouton +15s ;
* bouton pause ;
* affichage temps lisible.

Ne pas ajouter notification background maintenant sauf si simple et sans permission sensible problématique.

---

## 27. Plate calculator logic

Garder la logique existante si présente.
Sinon créer une utility simple :

```dart
class PlateLoad {
  const PlateLoad({
    required this.plate,
    required this.countPerSide,
  });

  final double plate;
  final int countPerSide;
}

List<PlateLoad> calculatePlates({
  required double targetWeight,
  double barWeight = 20,
  List<double> plates = const [25, 20, 15, 10, 5, 2.5, 1.25],
}) {
  final sideWeight = (targetWeight - barWeight) / 2;
  if (sideWeight <= 0) return [];

  var remaining = sideWeight;
  final result = <PlateLoad>[];

  for (final plate in plates) {
    final count = remaining ~/ plate;
    if (count > 0) {
      result.add(PlateLoad(plate: plate, countPerSide: count));
      remaining -= count * plate;
    }
  }

  return result;
}
```

---

## 28. Workout logger UX rules

Très important :

* Logging d’un set doit rester en maximum 1–2 taps.
* Les boutons doivent être gros.
* Les champs poids/reps/RPE doivent être faciles à toucher.
* Le dernier poids utilisé doit être visible ou accessible.
* `Same as last time` doit être visible.
* `Smart +` doit rester visible.
* Le rest timer ne doit pas bloquer le logging.
* L’utilisateur doit pouvoir ajouter un exercice rapidement.
* L’utilisateur doit pouvoir finir une séance clairement.

---

## 29. Données et confidentialité

Ne pas modifier la politique actuelle sans raison.

Interdictions dans cette phase :

* Pas de camera permission.
* Pas de photos permission.
* Pas de location.
* Pas de microphone.
* Pas de contacts.
* Pas de body sensors.
* Pas de Firebase.
* Pas de cloud sync.
* Pas d’analytics tiers.
* Pas de RevenueCat.

L’app reste locale/offline-first.

---

## 30. Tests à préserver

À la fin, exécuter :

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Tout doit passer.

Si les tests cassent :

* corriger le code ;
* ne pas supprimer les tests pour cacher le problème ;
* garder les repositories existants ;
* garder les providers existants.

---

## 31. Priorités exactes d’exécution

Travailler dans cet ordre :

1. Mettre à jour `app_theme.dart`.
2. Ajouter `if_text_styles.dart`.
3. Ajouter les composants design system.
4. Remplacer `ForgeShell` avec bottom navigation.
5. Ajouter route `/history`.
6. Ajouter route `/ai-coach`.
7. Redesign Home.
8. Redesign Workout Logger.
9. Ajouter Rest Timer screen.
10. Ajouter Plate Calculator screen.
11. Redesign Progress.
12. Redesign Exercises.
13. Redesign Routines en Programs.
14. Redesign Onboarding.
15. Redesign Premium placeholder.
16. Ajouter PR celebration.
17. Ajouter assets folders et placeholders.
18. Mettre à jour `pubspec.yaml`.
19. Exécuter les commandes de validation.
20. Corriger toutes les erreurs.

---

## 32. Contraintes importantes

Ne pas faire :

* Ne pas supprimer Hive.
* Ne pas supprimer les tests existants.
* Ne pas ajouter Firebase maintenant.
* Ne pas ajouter RevenueCat maintenant.
* Ne pas ajouter permissions Android sensibles.
* Ne pas committer keystore.
* Ne pas committer `.jks`.
* Ne pas committer `.env`.
* Ne pas committer `android/key.properties`.
* Ne pas remplacer tout le projet par un template.
* Ne pas casser `com.ironforge.app`.
* Ne pas casser la sauvegarde offline.
* Ne pas casser les exercices custom.
* Ne pas casser les routines.
* Ne pas casser l’onboarding.

Faire :

* Garder la logique locale.
* Garder les repositories existants.
* Garder les providers existants.
* Améliorer les écrans existants.
* Ajouter seulement les fichiers nécessaires.
* Préserver `flutter analyze` sans erreurs.
* Préserver `flutter test`.
* Respecter la preview rouge/noir.
* Rendre l’app beaucoup plus premium.

---

## 33. Checklist finale

La version terminée doit avoir :

* [ ] Logo IronForge rouge/noir.
* [ ] App icon prête ou assets placeholders propres.
* [ ] Home dashboard proche de la preview.
* [ ] Workout logger dense et premium.
* [ ] Rest timer circulaire rouge.
* [ ] Plate calculator visuel.
* [ ] History screen.
* [ ] Exercise library style preview.
* [ ] Programs/Routines style preview.
* [ ] Progress overview avec tabs et chart rouge.
* [ ] AI Coach placeholder premium.
* [ ] Bottom navigation persistante.
* [ ] Couleur principale rouge, pas teal.
* [ ] Tous les textes visibles sur fond noir.
* [ ] Aucune permission sensible ajoutée.
* [ ] Hive toujours fonctionnel.
* [ ] Routines toujours persistantes.
* [ ] Exercices custom toujours persistants.
* [ ] Onboarding toujours persistant.
* [ ] `flutter analyze` OK.
* [ ] `flutter test` OK.
* [ ] `flutter build apk --debug` OK.

---

## 34. Validation visuelle contre la preview

Comparer écran par écran.

### Home

Doit montrer :

* IronForge branding.
* Greeting.
* Streak.
* Quote card.
* Start Workout rouge.
* Today's Plan.
* Stats cards.

### Workout Logger

Doit montrer :

* Bench Press ou Live Workout.
* Chips muscle/equipment.
* Warm-up sets ou section équivalente.
* Working sets.
* Same as last time.
* Smart +.
* Add set / Log set.
* Plate calculator.
* Rest timer compact.

### Rest Timer

Doit montrer :

* cercle rouge.
* temps au centre.
* -15 / pause / +15.
* vibration/sound rows.

### Plate Calculator

Doit montrer :

* kg/lbs toggle.
* total weight.
* barbell visual.
* plate list.
* total rouge.

### Progress

Doit montrer :

* tabs période.
* 1RM estimate.
* chart rouge.
* stat cards.

### History

Doit montrer :

* date groups.
* workout cards.
* exercise rows.

### Exercises

Doit montrer :

* search.
* chips.
* favorite stars.
* equipment grid.

### Programs

Doit montrer :

* tabs My Programs / Explore.
* program cards avec images/gradients.
* routines utilisateur modifiables.

### AI Coach

Doit montrer :

* insight card.
* recovery placeholder.
* volume analysis.

---

## 35. Textes UI recommandés

Home :

```text
Yo, Iron Titan 💪
Let's crush today.
Workout Streak
START WORKOUT
Today's Plan
Push Day
Volume
Workouts
Sets
Best Bench
```

Workout :

```text
Live Workout
Quick add exercise
Same as last time
Smart +
Log Set
Add Set
Plate Calculator
Exercise notes
Finish Workout
PR FORGED
```

Rest Timer :

```text
Rest Timer
RESTING
UP NEXT
Vibration
Sound
```

Plate Calculator :

```text
Plate Calculator
Total Weight
Plates per side
Bar
Total
```

Progress :

```text
Progress Overview
1RM Estimate
Total Volume
Total Workouts
PRs
Completed Sets
```

History :

```text
History
All
Workouts
PRs
Notes
No workouts yet.
Start your first session and forge your baseline.
```

Exercises :

```text
Exercises
Search exercises...
All
Chest
Back
Legs
Shoulders
Equipment
Custom Exercise
Favorites
```

Programs :

```text
Programs
My Programs
Explore
PPL 6 Day Split
5x5 Strength
Upper / Lower
Bro Split
```

AI Coach :

```text
AI Coach
Insight
View Recommendation
Recovery
Coming soon
Volume Analysis
```

---

## 36. Notes de qualité

Le but n’est pas seulement de rendre l’app jolie.

Le but est qu’un lifter puisse :

* ouvrir l’app en salle ;
* trouver son exercice en 2 secondes ;
* voir son dernier poids ;
* logger un set rapidement ;
* sentir un feedback haptique ;
* voir quand il bat un PR ;
* suivre sa progression ;
* avoir envie de revenir demain.

La performance et la lisibilité passent avant les animations lourdes.

---

## 37. Prompt court à utiliser après avoir ajouté ce fichier

Après avoir ajouté ce fichier à la racine du repo, utiliser ce message pour Codex :

```text
Lis `IRONFORGE_CODEX_REDESIGN_INSTRUCTIONS.md`. Ne repars pas de zéro. Le projet Flutter actuel est déjà fonctionnel en offline-first avec Hive. Tu dois transformer l’UI pour correspondre à la preview IronForge rouge/noir : home dashboard, workout logger dense, rest timer circulaire, plate calculator, progress, history, exercises, programs et AI coach placeholder. Garde Hive, les repositories, les tests, le package Android `com.ironforge.app`, et n’ajoute pas Firebase/RevenueCat maintenant. À la fin, exécute `flutter pub get`, `flutter analyze`, `flutter test`, puis `flutter build apk --debug`. Corrige toutes les erreurs avant de terminer.
```

Fin du document.
