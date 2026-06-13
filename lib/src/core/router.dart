import 'package:go_router/go_router.dart';

import '../features/exercises/presentation/exercise_library_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/premium/presentation/premium_screen.dart';
import '../features/progress/presentation/progress_screen.dart';
import '../features/routines/presentation/routines_screen.dart';
import '../features/workout_logger/presentation/home_screen.dart';
import '../features/workout_logger/presentation/workout_logger_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/workout', builder: (_, __) => const WorkoutLoggerScreen()),
    GoRoute(path: '/progress', builder: (_, __) => const ProgressScreen()),
    GoRoute(path: '/exercises', builder: (_, __) => const ExerciseLibraryScreen()),
    GoRoute(path: '/routines', builder: (_, __) => const RoutinesScreen()),
    GoRoute(path: '/premium', builder: (_, __) => const PremiumScreen()),
  ],
);
