import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../domain/user_profile.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  if (Hive.isBoxOpen(HiveUserProfileRepository.boxName)) {
    return HiveUserProfileRepository(Hive.box(HiveUserProfileRepository.boxName));
  }

  return InMemoryUserProfileRepository();
});

final userProfileProvider = FutureProvider<UserProfile?>((ref) {
  return ref.watch(userProfileRepositoryProvider).loadProfile();
});

abstract class UserProfileRepository {
  Future<UserProfile?> loadProfile();
  Future<void> saveProfile(UserProfile profile);
}

class HiveUserProfileRepository implements UserProfileRepository {
  HiveUserProfileRepository(this._box);

  static const boxName = 'user_profile';
  static const profileKey = 'profile';

  final Box<dynamic> _box;

  @override
  Future<UserProfile?> loadProfile() async {
    final value = _box.get(profileKey);
    if (value is! Map<dynamic, dynamic>) return null;
    return UserProfile.fromMap(value);
  }

  @override
  Future<void> saveProfile(UserProfile profile) {
    return _box.put(profileKey, profile.toMap());
  }
}

class InMemoryUserProfileRepository implements UserProfileRepository {
  UserProfile? _profile;

  @override
  Future<UserProfile?> loadProfile() async => _profile;

  @override
  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
  }
}
