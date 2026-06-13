import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/features/exercises/data/exercise_repository.dart';
import 'src/features/onboarding/data/user_profile_repository.dart';
import 'src/features/routines/data/routine_repository.dart';
import 'src/features/workout_logger/data/workout_repository.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(HiveWorkoutRepository.boxName);
  await Hive.openBox(HiveRoutineRepository.boxName);
  await Hive.openBox(HiveExerciseRepository.boxName);
  await Hive.openBox(HiveUserProfileRepository.boxName);

  runApp(const ProviderScope(child: IronForgeApp()));
}
