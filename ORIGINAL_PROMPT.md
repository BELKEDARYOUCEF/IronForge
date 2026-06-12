# Original Prompt From Mouad

You are an expert full-stack mobile developer and fitness app architect. Build a premium-grade, production-ready mobile fitness tracker app called "IronForge" (or suggest a better name) targeted at serious gym bros and powerlifters/bodybuilders who want the ultimate workout logging experience.

## Core Purpose

The app must solve the biggest pain point: never forgetting what weights, reps, and sets you did last session and making progressive overload effortless and addictive. It should feel like a personal trainer + data nerd + hype beast in your pocket.

## Must-Have Features (Non-Negotiable)

### 1. Workout Logger (The Heart)

One-tap "Start Workout" with quick exercise search/add.
Per exercise: multiple sets with weight (kg/lbs, auto-switch), reps, RPE (1-10), notes, and rest timer.
Auto-fill last used weight/reps for that exercise (with "Same as last time" button + smart suggestions based on recent history).
Supersets, drop sets, rest-pause, myo-reps, giant sets support.
Live rest timer with customizable times per exercise + vibration + sound.
Plate calculator (shows exact plates needed on bar).
Voice input for logging ( "Bench 4 sets of 8 at 100kg" ).

### 2. History & Progress Tracking

Beautiful timeline of all past workouts.
Exercise-specific history with line charts (strength curves), volume trends, PRs.
1RM estimator, E1RM, volume load, total tonnage.
Body measurements + progress photos (with side-by-side comparison slider).
Weekly/monthly/yearly stats dashboard with streaks and consistency score.

### 3. Exercise Library

1000+ exercises with proper form videos (YouTube embeds or local), muscle groups, equipment filters.
User-created custom exercises.
Favorites and "My Go-To" section.

### 4. Programs & Routines

Pre-built popular programs (PPL, Upper/Lower, 5x5, Push/Pull/Legs, Bro Splits, etc.).
Custom routine builder with drag-and-drop.
Program progression logic (auto-increase weight when you hit reps).

### 5. Premium-Only Features (Make people want to pay)

Cloud sync across devices (Firebase/Auth).
Advanced analytics & AI insights ("Your bench has been stuck for 3 weeks — try this deload" or "Volume too high on quads").
AI workout generator based on goals, available equipment, recovery.
Apple Watch / Wear OS companion (real-time heart rate, auto-set detection if possible).
Export to CSV / Apple Health / Google Fit / Strava.
Custom themes, widgets, home screen complications.
No ads, unlimited history, dark mode OLED perfection.
Community feed (optional, opt-in) — share PRs, lift videos, get hype comments.

### 6. Extra Gym Bro Features They Will Love

"PR Hunter" notifications when you're close to a personal record.
Workout streaks with motivational quotes/memes.
Lift music integration (Spotify/Apple Music playlist auto-start).
Gym check-in with location (optional).
Warm-up sets calculator.
Failure rate / form feedback notes.
Macro/nutrition quick logger (optional but integrated).
"Today's Pump" motivational home screen widget.
Leaderboards for specific lifts (anonymous or friends).

## Tech Stack (Best in Class)

Cross-platform: Flutter 3.24+ (best performance + beautiful UI for fitness apps) or React Native + Expo if you prefer. Prefer Flutter.
State Management: Riverpod or Bloc.
Backend: Firebase (Auth, Firestore, Storage, Cloud Functions) + optional Supabase for more SQL-like power.
Local Database: Isar or Hive for offline-first (critical for gym use).
Charts: Fl_Charts or Syncfusion.
Animations: Rive + Lottie for satisfying set completion animations.
Architecture: Clean Architecture + Repository pattern.
Other: GetIt, Dio, permission_handler, camera for progress pics, audio for timers, WorkManager for background sync.

## Design & UX Requirements

Dark, aggressive, premium aesthetic (blacks, electric accents, brutalist + modern gym vibe).
Extremely fast and finger-friendly — big buttons, minimal taps to log a set.
Haptic feedback everywhere (success feels good).
Offline-first: everything works without internet, syncs when back online.
Beautiful onboarding with goal selection (Hypertrophy, Strength, Powerbuilding, etc.).

## Monetization

Freemium model.
Free: unlimited logging for 3 exercises per workout, basic history.
Premium (one-time lifetime or $6.99–$9.99/month or $49.99/year): everything unlocked.
Implement revenuecat for subscriptions.

## Additional Instructions

Write clean, well-commented, production-ready code with proper error handling, loading states, and accessibility.
Include a complete folder structure.
Generate all main screens as separate files.
Include sample data for testing.
Make the app feel addictive — celebrate every PR, use confetti on milestones.
Add smart defaults and "gym bro mode" toggles (more aggressive language, memes, etc.).

Generate the full project structure with key files first, then drill down into the most important screens and logic (especially the workout logger and progress charts). After the code, give me a complete README with setup instructions and how to run it.
Start building it now.

Copy this prompt exactly (or tweak the name). It’s dense on purpose — it forces the AI to create something actually good instead of a basic todo-list style tracker.

Would you also like me to generate:

A Figma-style UI description?
Icon/app name suggestions?
Marketing copy for the App Store?

