# IRONFORGE — Plan d'exécution maître pour Claude Code

> Guide de pilotage pour redévelopper l'UI vers « 100% preview, données honnêtes » sans casser le code existant. Conçu pour le **vibe coding discipliné** : Claude Code travaille **une tâche atomique à la fois**, valide, commit, s'arrête. Tu pilotes, lui exécute.

---

## 0. COMMENT UTILISER CE PLAN

1. Ouvre le projet dans Claude Code (`claude` dans le dossier du repo).
2. Pour CHAQUE tâche ci-dessous, tu colles **uniquement le bloc de cette tâche** (pas tout le doc).
3. Claude Code fait la tâche, lance les checks, commit, et s'arrête.
4. Tu vérifies (analyze/test verts + tu lances l'app), puis tu passes à la tâche suivante.
5. Si quelque chose cloche → tu utilises un prompt de correction (section finale).

**Règle d'or à rappeler à Claude Code au début de chaque session :**
> Tu modifies UNIQUEMENT ce que la tâche demande. Tu ne touches pas à la logique Hive/providers/repositories/routes. Tu ne casses aucun test. Toute donnée affichée a une source réelle (Hive), une estimation étiquetée `est.`, ou un état "Coming soon". À la fin : `flutter analyze` + `flutter test`, puis commit, puis STOP.

---

## 1. SETUP — Mémoire projet (À FAIRE EN PREMIER, une seule fois)

Avant toute phase, crée le fichier de mémoire que Claude Code lira automatiquement à chaque session. Ça l'empêche de dériver.

### TÂCHE 0.1 — Créer CLAUDE.md
```
Crée un fichier CLAUDE.md à la racine du repo avec ce contenu exact, sans rien
modifier d'autre dans le projet :

# IronForge — Règles projet pour Claude Code

## Stack (ne pas changer)
Flutter 3.5+ / Dart 3 · Riverpod · GoRouter · Hive (offline-first, source de
vérité) · fl_chart · Package Android com.ironforge.app

## Interdits absolus
- Ne PAS ajouter Firebase, RevenueCat, permissions sensibles, capteurs santé.
- Ne PAS casser : Hive, repositories, providers, routes, tests, com.ironforge.app.
- Ne PAS reconstruire/templater. On densifie l'UI existante.
- Ne PAS afficher de nombre sans source. 3 statuts seulement :
  1) donnée Hive réelle  2) estimation étiquetée "est."  3) module "Coming soon".

## Objectif UI
Reproduire visuellement la preview IronForge rouge/noir : dense, cards compactes,
bordures fines 0.5px, tables de séries alignées, série active en highlight rouge.
Couleurs via IFColors. Rouge=action, Gold=PR, Vert=delta positif, Orange=streak,
Bleu=AI.

## Données honnêtes (traductions)
- Calories = estimation MET : 5.0 × poidsCorps(kg) × durée(h). Poids depuis
  UserProfile. Si absent → "—". Toujours suffixe "est.".
- Insight AI Coach = moteur de règles sur logs Hive (pas d'IA, pas de réseau).
- HRV/Sleep = module "Coming soon" premium.
- Recovery % = score de régularité réel (séances ÷ objectif hebdo).

## Workflow obligatoire
1 tâche à la fois → flutter analyze (0 erreur) → flutter test (tout passe) →
commit clair → STOP. Grosses phases UI : flutter build apk --debug.

Puis lance `flutter analyze` pour vérifier que rien n'est cassé. Commit :
"Add CLAUDE.md project memory". Stop.
```

---

## 2. PHASES & TÂCHES ATOMIQUES

Chaque phase = 1 à 3 tâches atomiques. Une tâche = un commit. Ne jamais enchaîner deux tâches sans validation.

---

### PHASE 1 — Fondations & design system

**TÂCHE 1.1 — Audit + constantes de densité**
```
Lis lib/src/core/app_theme.dart et lib/src/shared/widgets/. Ne réécris RIEN qui
fonctionne déjà. Crée seulement un fichier lib/src/core/if_spacing.dart avec des
constantes de densité réutilisables (radius card 16, radius input 11, spacing
blocs 12, padding card 13, bordure 0.5) pour uniformiser. Remplace les valeurs
magiques dispersées par ces constantes UNIQUEMENT dans les widgets Forge* partagés.
flutter analyze + test. Commit "Add density tokens to design system". Stop.
```

**TÂCHE 1.2 — Service calories (utilitaire honnête, sans UI)**
```
Crée lib/src/features/workout_logger/domain/calorie_estimator.dart : une fonction
pure estimateKcal({required double bodyWeightKg, required Duration duration})
=> 5.0 * bodyWeightKg * duration.inMinutes / 60, arrondie. Si bodyWeightKg <= 0,
retourne null. Ajoute un test unitaire dans test/. N'utilise ce service nulle part
encore (juste le créer + tester). flutter analyze + test.
Commit "Add MET calorie estimator with tests". Stop.
```

**TÂCHE 1.3 — Service moteur de règles AI Coach (logique pure, sans UI)**
```
Crée lib/src/features/ai_coach/domain/coach_engine.dart : un service qui prend
List<WorkoutSession> et retourne List<CoachInsight> (max 3, triés par priorité).
Implémente les règles : stagnation E1RM (>=3 séances sans progrès), hausse volume
hebdo (>=10%), PR récent (7j), baisse de fréquence vs objectif. CoachInsight =
{title, body, tone: positive/neutral/alert}. Si rien ne matche → 1 insight neutre
encourageant. Ajoute des tests unitaires avec sessions simulées. NE touche pas
encore à l'écran AI Coach. flutter analyze + test.
Commit "Add offline AI coach rules engine with tests". Stop.
```

---

### PHASE 2 — Home (100% preview honnête)

**TÂCHE 2.1 — Densifier le layout Home**
```
Lis lib/src/features/workout_logger/presentation/home_screen.dart. Reproduis la
densité de la preview : streak et PR en deux cards côte à côte (pas une grande
card), métriques en RANGÉE DE 4 tuiles compactes (Volume/Séances/Séries/Bench),
quote card compacte, Today's Plan compact. Garde TOUTES les sources de données
Hive existantes. Réutilise les widgets Forge* et les density tokens. Ne touche
pas à la logique de calcul. flutter analyze + test.
Commit "Densify home dashboard layout". Stop.
```

**TÂCHE 2.2 — Calories estimées dans Today's Plan**
```
Dans home_screen.dart (et/ou le résumé de séance), affiche les calories via le
calorie_estimator créé en tâche 1.2, en lisant le poids depuis UserProfile et la
durée de séance. Suffixe "est." discret. Si poids absent → afficher "—". AUCUNE
valeur en dur. flutter analyze + test.
Commit "Show estimated calories in today's plan". Stop.
```

---

### PHASE 3 — Workout logger (l'écran roi)

**TÂCHE 3.1 — Table de séries warm-up/working**
```
Lis workout_logger_screen.dart en entier d'abord. Densifie la table de séries pour
matcher la preview : sections WARM UP et WORKING SETS séparées par labels, colonnes
alignées (n° | poids | reps | RPE | check), lignes ~36-40px. Série active en
highlight rouge (fond sombre + bordure rouge). Garde 100% de la logique existante
(addSet, sameAsLast, smartSet, updateSet, deleteSet, notes, kg/lbs, PR, haptics,
finish). Ne change aucun nom de provider/méthode. flutter analyze + test.
Commit "Densify workout logger set table". Stop.
```

**TÂCHE 3.2 — Suggestion overload + actions compactes**
```
Ajoute la ligne de suggestion inline ("Last time: Xkg × Y · try +2.5kg") basée sur
le dernier set réel de l'exercice (donnée Hive existante, pas inventée). Compacte
les boutons ADD SET / PLATES / SAME AS LAST en barre dense. Ne touche pas au timer.
flutter analyze + test + flutter build apk --debug.
Commit "Add inline overload hint and compact actions". Stop.
```

---

### PHASE 4 — Rest timer + plate calculator

**TÂCHE 4.1 — Rest timer compact**
```
Densifie rest_timer_screen.dart : grand cercle rouge avec temps au centre,
boutons -15s / pause / +15s, lignes vibration/son. Garde la logique de timer.
flutter analyze + test. Commit "Polish rest timer screen". Stop.
```

**TÂCHE 4.2 — Plate calculator visuel**
```
Densifie plate_calculator_screen.dart : toggle KG/LBS, poids total en grand,
barbell visuel avec disques colorés, liste des plaques par côté, total rouge.
Garde la logique de calcul existante. flutter analyze + test.
Commit "Polish plate calculator screen". Stop.
```

---

### PHASE 5 — History

**TÂCHE 5.1 — History dense**
```
Densifie history_screen.dart : tabs All/Workouts/PRs/Notes, sessions groupées par
date, workout cards compactes (durée, volume, nb exercices), rows d'exercices avec
meilleur poids, badge PR doré si applicable, empty state premium. Données via
workoutHistoryProvider réel. flutter analyze + test.
Commit "Densify workout history screen". Stop.
```

---

### PHASE 6 — Progress

**TÂCHE 6.1 — Progress dense**
```
Densifie progress_screen.dart : tabs période (7D/4W/3M/1Y/ALL), card hero "1RM
Estimate" avec grande valeur + delta vert, courbe rouge fl_chart, 4 stat cards
(Total Volume/Workouts/PRs/Sets). Données ProgressStats réelles uniquement.
flutter analyze + test. Commit "Densify progress overview". Stop.
```

---

### PHASE 7 — Exercises

**TÂCHE 7.1 — Exercises dense**
```
Densifie exercise_library_screen.dart : search field sombre, chips de filtres
(All/Chest/Back/Legs/Custom), rows compactes avec icône + équipement + muscle +
étoile favori, grille équipement en bas. Garde favoris/custom/recherche Hive
intacts. flutter analyze + test. Commit "Densify exercise library". Stop.
```

---

### PHASE 8 — Programs + AI Coach honnête

**TÂCHE 8.1 — Programs dense**
```
Densifie routines_screen.dart en écran Programs : tabs My Programs/Explore, cards
programmes avec bandeau dégradé rouge, titre, niveau/fréquence, badge POPULAR,
étoile favori. Les routines Hive de l'utilisateur restent créables/modifiables/
supprimables. flutter analyze + test. Commit "Densify programs screen". Stop.
```

**TÂCHE 8.2 — Brancher le moteur de règles dans AI Coach**
```
Dans ai_coach_screen.dart : remplace l'insight statique par les CoachInsight du
coach_engine (tâche 1.3) calculés sur les sessions Hive. Remplace le "82% recovery"
en dur par un anneau CONSISTENCY = séances réelles ÷ objectif hebdo (UserProfile),
borné 0-100%. Volume analysis = vrai chart fl_chart sur volume Hive. Sleep/HRV
restent en "Coming soon" propre. AUCUN nombre en dur. flutter analyze + test.
Commit "Wire honest AI coach with rules engine". Stop.
```

---

### PHASE 9 — Polish & QA

**TÂCHE 9.1 — Uniformisation visuelle**
```
Passe en revue tous les écrans. Uniformise radius, bordures, spacing, tailles de
badges, hiérarchie typo via les density tokens. Corrige tout overflow. Ne change
aucune logique. flutter analyze + test. Commit "Final visual consistency pass". Stop.
```

**TÂCHE 9.2 — Audit anti-fausses-données + build**
```
Cherche dans tout lib/ tout nombre affiché sans source réelle. Vérifie : calories
ont "est." et viennent du estimator, insights viennent du coach_engine, HRV/Sleep
en "Coming soon", consistency calculé. Corrige les écarts. Puis :
flutter pub get && flutter analyze && flutter test && flutter build apk --debug.
Commit "Honest-data QA and release-ready build". Stop.
```

---

## 3. CHECKLIST DE VALIDATION (à toi, après chaque tâche)

Avant de passer à la tâche suivante, vérifie :
- [ ] `flutter analyze` → No issues found
- [ ] `flutter test` → tous verts
- [ ] L'app lance et l'écran modifié ressemble à la preview
- [ ] Aucun nombre suspect (calories sans "est.", recovery en dur, etc.)
- [ ] Le commit est clair et atomique
- [ ] Claude Code s'est bien ARRÊTÉ (n'a pas enchaîné)

---

## 4. PROMPTS DE CORRECTION (à garder sous la main)

**Pas assez proche de la preview :**
```
L'écran n'est pas à 100% de la preview. Ne passe pas à la suite. Resserre la
densité (spacing 12, cards 13, table alignée, série active highlight rouge) et
reproduis le layout de la preview pour cet écran. Données honnêtes uniquement.
flutter analyze + test, commit un fix.
```

**Fausse donnée :**
```
Tu affiches un nombre sans source. 3 statuts autorisés : donnée Hive réelle,
estimation "est.", ou "Coming soon". Corrige cet élément. flutter analyze + test,
commit le fix.
```

**Logique cassée :**
```
Tu as cassé une logique (Hive/provider/controller/calcul). Ne continue pas. Répare
la régression, garde l'UI densifiée, ne supprime aucun test. flutter analyze +
test, commit le fix.
```

**Dépassement / dispersion :**
```
Tu sors du périmètre de la tâche. Reviens au scope exact. Annule ce qui ne concerne
pas cette tâche, sauf strict nécessaire pour compiler. Une tâche = un commit.
```

---

## 5. ORDRE RÉCAPITULATIF (ta feuille de route)

```
0.1 CLAUDE.md
1.1 density tokens   1.2 calorie estimator   1.3 coach engine
2.1 home layout      2.2 home calories
3.1 logger table     3.2 logger overload
4.1 rest timer       4.2 plate calculator
5.1 history
6.1 progress
7.1 exercises
8.1 programs         8.2 ai coach honnête
9.1 consistency UI   9.2 anti-fake QA + build
```

15 tâches atomiques, 15 commits propres. Tu avances à ton rythme, une à la fois.
```
