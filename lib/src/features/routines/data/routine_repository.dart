import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../domain/routine.dart';

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  if (Hive.isBoxOpen(HiveRoutineRepository.boxName)) {
    return HiveRoutineRepository(Hive.box(HiveRoutineRepository.boxName));
  }

  return InMemoryRoutineRepository();
});

final routinesProvider = FutureProvider<List<Routine>>((ref) {
  return ref.watch(routineRepositoryProvider).loadRoutines();
});

abstract class RoutineRepository {
  Future<List<Routine>> loadRoutines();
  Future<void> saveRoutine(Routine routine);
  Future<void> deleteRoutine(String id);
}

class HiveRoutineRepository implements RoutineRepository {
  HiveRoutineRepository(this._box);

  static const boxName = 'routines';

  final Box<dynamic> _box;

  @override
  Future<List<Routine>> loadRoutines() async {
    final routines = _box.values
        .whereType<Map<dynamic, dynamic>>()
        .map(Routine.fromMap)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return List.unmodifiable(routines);
  }

  @override
  Future<void> saveRoutine(Routine routine) {
    return _box.put(routine.id, routine.toMap());
  }

  @override
  Future<void> deleteRoutine(String id) {
    return _box.delete(id);
  }
}

class InMemoryRoutineRepository implements RoutineRepository {
  final _routines = <Routine>[];

  @override
  Future<List<Routine>> loadRoutines() async => List.unmodifiable(_routines);

  @override
  Future<void> saveRoutine(Routine routine) async {
    final index = _routines.indexWhere((item) => item.id == routine.id);
    if (index == -1) {
      _routines.add(routine);
    } else {
      _routines[index] = routine;
    }
  }

  @override
  Future<void> deleteRoutine(String id) async {
    _routines.removeWhere((routine) => routine.id == id);
  }
}
