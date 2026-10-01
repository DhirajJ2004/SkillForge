import '../models/practice_model.dart';
import '../services/storage_service.dart';

class PracticeRepository {
  final StorageService _storage;

  PracticeRepository(this._storage);

  List<PracticeAttempt> getAttempts() {
    return _storage.getPracticeAttempts();
  }

  Future<void> recordAttempt(PracticeAttempt attempt) async {
    await _storage.addPracticeAttempt(attempt);
  }

  PracticeStatsSummary getStatsSummary() {
    final attempts = getAttempts();
    return PracticeStatsSummary.fromAttempts(attempts);
  }

  double getHighestAccuracy() {
    final attempts = getAttempts();
    if (attempts.isEmpty) return 0.0;
    return attempts
        .map((a) => a.accuracy)
        .reduce((a, b) => a > b ? a : b);
  }

  int getTotalQuestionsAttempted() {
    final attempts = getAttempts();
    return attempts.fold(0, (sum, a) => sum + a.totalQuestions);
  }

  int getTotalCorrectAnswers() {
    final attempts = getAttempts();
    return attempts.fold(0, (sum, a) => sum + a.score);
  }
}
