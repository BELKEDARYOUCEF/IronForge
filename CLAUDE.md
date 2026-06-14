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
