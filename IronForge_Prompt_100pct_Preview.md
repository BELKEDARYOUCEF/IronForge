# PROMPT REDÉVELOPPÉ — IronForge « 100% PREVIEW, DONNÉES HONNÊTES »

> Objectif : reproduire **visuellement 100% de la preview IronForge rouge/noir** (densité, layout, tables, cards, courbes, programmes) **sans une seule fausse donnée**. Là où la preview montre une donnée non mesurable en offline-first, on la remplace par une version honnête qui rend AUSSI bien : calories **estimées par calcul**, insight **calculé par moteur de règles sur Hive**, capteurs en **"Coming soon" premium**. Le code existant est déjà bon : on densifie et on raffine, on ne reconstruit pas.

---

## CONTEXTE (coller en tête de session)

```
Repo : https://github.com/BELKEDARYOUCEF/IronForge
Branche : main
Framework : Flutter 3.5+, Dart 3
Package Android : com.ironforge.app
DB : Hive (offline-first, source de vérité unique)
State : Riverpod · Routing : GoRouter · Charts : fl_chart

L'app a DÉJÀ : Clean Architecture, repositories Hive, providers, design system
maison (Forge*), workout logger (~1088 lignes), history, progress, exercises,
routines, onboarding, AI coach, tests qui passent.

NE PAS reconstruire / repartir de zéro / templater.
NE PAS ajouter Firebase, RevenueCat, permissions sensibles, capteurs santé réels.
NE PAS casser : Hive, repositories, providers, routes, tests, com.ironforge.app.

Lecture obligatoire avant modif :
1. IRONFORGE_CODEX_REDESIGN_INSTRUCTIONS.md
2. travail_codex.md
3. lib/src/core/app_theme.dart
4. lib/src/core/router.dart
5. lib/src/shared/widgets/
6. l'écran de la phase en cours
```

---

## DOCTRINE « 100% PREVIEW, ZÉRO MENSONGE »

La preview est la **spec visuelle de référence**. On reproduit son apparence à l'identique : densité, hiérarchie, couleurs, tables, cards, badges, courbes.

**Règle d'or :** chaque nombre affiché a une source réelle. Trois statuts autorisés, jamais un quatrième :
1. **Donnée réelle Hive** (volume, séries, PR, E1RM, streak, historique).
2. **Estimation calculée** explicitement étiquetée `est.` (ex : calories).
3. **Module "Coming soon"** stylé premium (capteurs : HRV, Sleep).

Interdit : un nombre en dur déguisé en mesure (ex : `82%` recovery sorti de nulle part).

---

## TRADUCTION PREVIEW → IMPLÉMENTATION HONNÊTE

Pour chaque élément de la preview qui n'est pas une donnée Hive directe :

| Élément preview | Implémentation honnête (à coder) |
|---|---|
| **Calories `1,247 kcal`** (Today's Plan / résumé séance) | **Estimation MET.** `kcal ≈ 5.0 × poidsCorps(kg) × durée(h)`. Poids depuis `UserProfile` (onboarding). Si poids absent → afficher `—` (jamais un faux chiffre). Toujours afficher le suffixe `est.` discret. Le visuel (icône flamme + valeur + label) reste **identique à la preview**. |
| **AI Coach insight** (« bench stuck 3 weeks ») | **Moteur de règles sur Hive** (voir section dédiée). Affichage identique à la preview (card INSIGHT bleue, texte, bouton VIEW). Mais le texte est généré par les règles, donc vrai. |
| **Recovery `82%`** | **Calcul réel** : score de régularité = séances réelles ÷ objectif hebdo (`UserProfile.frequencyPerWeek`), borné 0–100%. Affichage anneau identique preview, label `CONSISTENCY` au lieu de `RECOVERY` (puisque c'est ça qu'on mesure vraiment). |
| **Sleep `7h45` / HRV `62ms`** | **Module "Coming soon"** premium : lignes verrouillées, icône cadenas discret, badge `COMING SOON`. Visuellement soigné, pas un placeholder moche. |
| **`Join 250K+ lifters`** (landing) | Remplacer par une **vraie stat locale** valorisante : `Your legacy starts here` + compteur réel (`X séances · Y PR · Z jours de streak`). Même emplacement, même style CTA rouge. |
| **Volume analysis chart** (AI Coach) | **fl_chart sur volume Hive réel** par semaine. Identique visuellement. |
| **Strength curve** (Progress) | Déjà réelle (E1RM Hive). Garder, densifier. |

---

## MOTEUR DE RÈGLES — AI COACH (offline, gratuit, honnête)

Créer un service pur Dart (testable) qui lit les `WorkoutSession` Hive et retourne 1–3 `CoachInsight` triés par priorité. Aucune IA, aucun réseau. Règles minimales :

```
RÈGLE 1 — Stagnation
Si le meilleur E1RM d'un exercice clé n'a pas progressé sur >= 3 séances
→ "Ton {exercice} stagne depuis {n} séances. Tente un deload de 10% ou varie les reps."

RÈGLE 2 — Hausse de volume (positif)
Si volume hebdo actuel > volume hebdo précédent de >= 10%
→ "Ton volume {muscle/global} a grimpé de +{x}% sur {n} semaines. Solide surcharge — garde le RPE < 9."

RÈGLE 3 — Déséquilibre push/pull
Si ratio volume push/pull s'écarte de >1.5x sur 4 semaines
→ "Déséquilibre {push}/{pull} détecté ({ratio}). Ajoute du volume {côté faible}."

RÈGLE 4 — PR récent (hype)
Si un PR a été battu dans les 7 derniers jours
→ "Nouveau PR sur {exercice} : {valeur}. Capitalise, ne brûle pas les étapes."

RÈGLE 5 — Baisse de fréquence
Si séances cette semaine < objectif hebdo (UserProfile) ET semaine bien entamée
→ "Tu es à {x}/{objectif} séances cette semaine. {reste} séance(s) pour tenir le cap."

Si aucune règle ne matche → insight neutre encourageant basé sur la dernière séance réelle.
```

Chaque insight = `{titre, texte, ton: positif/neutre/alerte, exerciceRef?}`. Couvrir le service par des tests unitaires (données Hive simulées).

---

## DESIGN — DENSITÉ CIBLE (= preview)

Réutiliser `IFColors` + widgets `Forge*`. Rouge = action · Gold = PR · Vert = delta positif · Orange = streak · Bleu = AI.

- Cards : padding 12–14, radius 14–16, bordure fine 0.5px.
- Spacing vertical entre blocs : 10–12.
- **Tables de séries** : `n° | poids | reps | RPE | check`, lignes 36–40px, **warm-up et working sets séparés** par labels.
- **Série active** = highlight rouge (fond `#1a0606`, bordure `red`).
- Home : streak + PR en cards côte à côte, métriques en **rangée de 4** tuiles compactes, Today's Plan compact avec calories `est.`.
- Programs : cards denses avec dégradé/visuel, badges niveau/fréquence, étoile favori.
- Progress : tabs période (7D/4W/3M/1Y/ALL), hero 1RM estimé + delta vert, courbe rouge, stat cards.
- AI Coach : card INSIGHT (texte du moteur de règles), volume chart réel, anneau CONSISTENCY, bloc capteurs Coming soon.
- Badges : pilule 9–10px semibold.

---

## RÈGLE DE TRAVAIL — UNE PHASE À LA FOIS (non négociable)

Pour chaque phase : lire → modifier UNIQUEMENT l'écran de la phase → densifier vers la preview → appliquer la traduction honnête des données → garder 100% de la logique → `flutter analyze` (0 erreur) → `flutter test` (tout passe) → commit clair → résumer → STOP.
Grosses phases UI : `flutter build apk --debug`. Ne jamais supprimer un test pour faire passer le build.

---

## PHASES (donner UNE seule à la fois)

**Phase 1 — Design system & densité.** Vérifier/uniformiser `IFColors` + widgets `Forge*`. Ne pas réécrire ce qui marche. Constantes de densité (radius/spacing). Commit : `Polish IronForge design system density`.

**Phase 2 — Home 100% preview honnête.** Streak & PR côte à côte, métriques rangée de 4, Today's Plan compact AVEC calories estimées MET (`est.`, `—` si pas de poids). Landing/hero : vraie stat locale au lieu de 250K. Commit : `Densify home and add estimated calories`.

**Phase 3 — Workout logger 100% preview.** Table warm-up/working séparée, colonnes poids/reps/RPE/check, série active highlight rouge, suggestion overload inline, rest timer compact. Garder addSet/sameAsLast/smartSet/updateSet/deleteSet/PR/haptics/finish. Commit : `Densify workout logger set table`.

**Phase 4 — Rest timer + plate calculator.** Grand cercle rouge timer (-15/pause/+15), toggle KG/LBS, poids total grand, barbell visuel, liste plates, total rouge. Commit : `Polish rest timer and plate calculator`.

**Phase 5 — History 100% preview.** Tabs All/Workouts/PRs/Notes, groupes par date, workout cards compactes, rows exercices + meilleur poids, empty state premium. workoutHistoryProvider réel. Commit : `Densify workout history screen`.

**Phase 6 — Progress 100% preview.** Tabs période, hero 1RM estimé + delta, courbe rouge fl_chart, stat cards (Volume/Workouts/PRs/Sets). ProgressStats réel. Commit : `Densify progress overview`.

**Phase 7 — Exercises 100% preview.** Search sombre, chips filtres, rows compactes + favorite star, equipment grid. Favoris/custom Hive intacts. Commit : `Densify exercise library`.

**Phase 8 — Programs + AI Coach honnête.** Programs : tabs My/Explore, cards programmes denses (PPL/5x5/Upper-Lower/Bro Split), favoris, routines Hive intactes. AI Coach : brancher le **moteur de règles** (insight réel), volume chart Hive, anneau CONSISTENCY (= calcul régularité), capteurs Coming soon. Commit : `Densify programs and wire honest AI coach`.

**Phase 9 — Polish & QA.** Uniformiser radius/bordures/spacing/typo. Vérifier qu'AUCUN nombre n'est en dur sans source (sauf labels). Calories ont bien `est.`, insights viennent du moteur, capteurs en Coming soon. Overflows. `flutter pub get && analyze && test && build apk --debug`. Commit : `Final polish and honest-data QA`.

---

## PROMPTS DE CORRECTION

**Pas assez proche de la preview :**
```
L'écran n'est pas encore à 100% de la preview. Ne passe pas à la phase suivante.
Resserre la densité (spacing 10-12, cards 12-14, table de séries alignée, série
active highlight rouge) et reproduis fidèlement le layout de la preview pour cet
écran. Données honnêtes uniquement. flutter analyze + test, commit un fix.
```

**Fausse donnée détectée :**
```
Tu affiches un nombre sans source. 3 statuts autorisés seulement : donnée Hive
réelle, estimation étiquetée 'est.', ou module 'Coming soon'. Corrige cet élément
en conséquence (calories = formule MET, insight = moteur de règles, capteur =
Coming soon). flutter analyze + test, commit le fix.
```

**Logique cassée :**
```
Tu as cassé une logique (Hive/provider/controller/calcul). Ne continue pas.
Répare la régression, garde l'UI densifiée, ne supprime aucun test.
flutter analyze + test, commit le fix.
```

**Dépassement de phase :**
```
Hors périmètre. Reviens au scope de cette phase. Annule ce qui ne la concerne pas,
sauf strict nécessaire pour compiler.
```
```
```
