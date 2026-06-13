import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/sample_data.dart';
import '../domain/exercise.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  if (Hive.isBoxOpen(HiveExerciseRepository.boxName)) {
    return HiveExerciseRepository(Hive.box(HiveExerciseRepository.boxName));
  }

  return InMemoryExerciseRepository();
});

final exercisesProvider = FutureProvider<List<Exercise>>((ref) {
  return ref.watch(exerciseRepositoryProvider).loadExercises();
});

abstract class ExerciseRepository {
  Future<List<Exercise>> loadExercises();
  Future<void> saveExercise(Exercise exercise);
  Future<void> deleteExercise(String id);
  Future<void> toggleFavorite(Exercise exercise);
}

class HiveExerciseRepository implements ExerciseRepository {
  HiveExerciseRepository(this._box);

  static const boxName = 'exercises';

  final Box<dynamic> _box;

  @override
  Future<List<Exercise>> loadExercises() async {
    final saved = {
      for (final value in _box.values.whereType<Map<dynamic, dynamic>>())
        Exercise.fromMap(value).id: Exercise.fromMap(value),
    };

    final merged = [
      for (final sample in sampleExercises) saved[sample.id] ?? sample,
      for (final exercise in saved.values)
        if (!sampleExercises.any((sample) => sample.id == exercise.id)) exercise,
    ]..sort((a, b) => a.name.compareTo(b.name));

    return List.unmodifiable(merged);
  }

  @override
  Future<void> saveExercise(Exercise exercise) {
    return _box.put(exercise.id, exercise.toMap());
  }

  @override
  Future<void> deleteExercise(String id) {
    return _box.delete(id);
  }

  @override
  Future<void> toggleFavorite(Exercise exercise) {
    return saveExercise(exercise.copyWith(isFavorite: !exercise.isFavorite));
  }
}

class InMemoryExerciseRepository implements ExerciseRepository {
  final _saved = <String, Exercise>{};

  @override
  Future<List<Exercise>> loadExercises() async {
    return [
      for (final sample in sampleExercises) _saved[sample.id] ?? sample,
      for (final exercise in _saved.values)
        if (!sampleExercises.any((sample) => sample.id == exercise.id)) exercise,
    ];
  }

  @override
  Future<void> saveExercise(Exercise exercise) async {
    _saved[exercise.id] = exercise;
  }

  @override
  Future<void> deleteExercise(String id) async {
    _saved.remove(id);
  }

  @override
  Future<void> toggleFavorite(Exercise exercise) async {
    await saveExercise(exercise.copyWith(isFavorite: !exercise.isFavorite));
  }
}
