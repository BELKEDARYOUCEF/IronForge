# IronForge Project Prompt

## Original Brief

Build a premium-grade, production-ready mobile fitness tracker app called **IronForge**, targeted at serious gym users, powerlifters, and bodybuilders who want the ultimate workout logging experience.

The app must solve the biggest pain point: never forgetting what weights, reps, and sets were used last session, while making progressive overload effortless and addictive. It should feel like a personal trainer, data analyst, and hype coach in one pocket app.

## Improved Product Direction

**IronForge** should be an offline-first workout tracker focused on speed during training. The core loop is:

1. Start workout in one tap.
2. Add or select exercises quickly.
3. Log sets with smart defaults from the last session.
4. Celebrate PRs and show clear progressive overload suggestions.
5. Sync and analyze data after the session.

The MVP should avoid becoming bloated. The first production milestone should prioritize the workout logger, exercise history, PR tracking, routines, offline storage, and premium-ready architecture.

## Product Pillars

- **Fast logging:** large controls, minimal taps, one-hand friendly.
- **Progressive overload:** smart previous-set autofill, PR detection, warm-up suggestions, and next-session recommendations.
- **Offline-first:** full workout logging must work without internet.
- **Premium feel:** OLED dark UI, electric accent colors, haptics, animations, and clean analytics.
- **Expandable architecture:** Firebase, RevenueCat, wearables, AI insights, and community can be added without rewriting the app.

## MVP Scope

### Workout Logger

- One-tap start workout.
- Exercise search and add.
- Multiple sets per exercise.
- Weight, reps, RPE, notes, and rest timer.
- Same-as-last-time button.
- Smart suggested next set.
- Superset/drop/rest-pause metadata support in the model.
- Plate calculator utility.
- PR detection and set-completion celebration.

### History And Progress

- Workout timeline.
- Exercise history.
- Volume, tonnage, E1RM, and PR calculations.
- Dashboard cards for weekly/monthly stats.
- Basic line chart-ready data models.

### Exercise Library

- Seed sample exercises.
- Muscle group and equipment filters.
- Custom exercise model.
- Favorites/go-to flags.

### Routines

- PPL, Upper/Lower, 5x5, and Bro Split seed routines.
- Routine builder architecture.
- Progression rule model.

### Premium Architecture

- Feature gates for:
  - unlimited exercises per workout,
  - advanced analytics,
  - cloud sync,
  - AI insights,
  - exports,
  - themes.
- RevenueCat integration placeholder.
- Firebase repository placeholder.

## Recommended Name

Keep **IronForge**. It is short, masculine, memorable, and fits the training/progressive overload metaphor.

Alternative names:

- ForgeSet
- PRForge
- TitanLog
- Overload
- RepSmith

## Implementation Decisions

- Framework: Flutter.
- State: Riverpod.
- Architecture: feature-first Clean Architecture style.
- Local-first persistence: repository interface now, Isar/Hive implementation later.
- Charts: fl_chart-ready progress models.
- Backend: Firebase-ready repository boundary.
- Premium: RevenueCat-ready service boundary.

