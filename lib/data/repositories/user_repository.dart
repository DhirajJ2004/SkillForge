import '../models/user_profile.dart';
import '../services/storage_service.dart';

class UserRepository {
  final StorageService _storage;

  UserRepository(this._storage);

  UserProfile getProfile() => _storage.getProfile();

  Future<void> updateProfile(UserProfile profile) async {
    await _storage.saveProfile(profile);
  }

  Future<void> completeOnboarding({
    required String name,
    required int dailyGoalMinutes,
    required int preferredStudyTimeHour,
    required int preferredStudyTimeMinute,
    required List<int> studyDays,
  }) async {
    final current = getProfile();
    final updated = current.copyWith(
      name: name,
      dailyGoalMinutes: dailyGoalMinutes,
      preferredStudyTimeHour: preferredStudyTimeHour,
      preferredStudyTimeMinute: preferredStudyTimeMinute,
      studyDays: studyDays,
      isOnboarded: true,
      createdAt: DateTime.now(),
    );
    await _storage.saveProfile(updated);
  }
}
