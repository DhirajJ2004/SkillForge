import '../models/study_session.dart';
import '../services/storage_service.dart';

class StudySessionRepository {
  final StorageService _storage;

  StudySessionRepository(this._storage);

  List<StudySession> getSessions() => _storage.getStudySessions();

  Future<void> recordSession(StudySession session) async {
    await _storage.addStudySession(session);
  }

  int getTotalStudyMinutes() {
    final sessions = getSessions();
    return sessions.fold(0, (sum, s) => sum + s.durationMinutes);
  }

  int getTodayStudyMinutes() {
    final sessions = getSessions();
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    return sessions
        .where((s) => !s.startTime.isBefore(startOfToday))
        .fold(0, (sum, s) => sum + s.durationMinutes);
  }

  int getWeeklyStudyMinutes() {
    final sessions = getSessions();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonday = DateTime(weekStart.year, weekStart.month, weekStart.day);

    return sessions
        .where((s) => !s.startTime.isBefore(startOfMonday))
        .fold(0, (sum, s) => sum + s.durationMinutes);
  }

  int getMonthlyStudyMinutes() {
    final sessions = getSessions();
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    return sessions
        .where((s) => !s.startTime.isBefore(startOfMonth))
        .fold(0, (sum, s) => sum + s.durationMinutes);
  }

  int getStudyDaysThisWeek() {
    final sessions = getSessions();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfMonday = DateTime(weekStart.year, weekStart.month, weekStart.day);

    final Set<String> activeDays = {};
    for (final s in sessions) {
      if (!s.startTime.isBefore(startOfMonday)) {
        activeDays.add('${s.startTime.year}-${s.startTime.month}-${s.startTime.day}');
      }
    }
    return activeDays.length;
  }

  // Calculate real consecutive days streak
  int calculateCurrentStreak([int minMinutesPerDay = 1]) {
    final threshold = minMinutesPerDay > 0 ? minMinutesPerDay : 1;
    final sessions = getSessions();
    if (sessions.isEmpty) return 0;

    // Group minutes by calendar date YYYY-MM-DD
    final Map<String, int> dailyMinutes = {};
    for (final s in sessions) {
      final dateKey =
          '${s.startTime.year}-${s.startTime.month.toString().padLeft(2, '0')}-${s.startTime.day.toString().padLeft(2, '0')}';
      dailyMinutes[dateKey] = (dailyMinutes[dateKey] ?? 0) + s.durationMinutes;
    }

    final now = DateTime.now();
    DateTime checkDate = DateTime(now.year, now.month, now.day);
    int streak = 0;

    final todayKey =
        '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';

    // If today has met minimum study minutes, start from today
    // If not yet met today, check if yesterday was completed (so streak isn't lost before today's study)
    if ((dailyMinutes[todayKey] ?? 0) >= threshold) {
      streak++;
      checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
    } else {
      checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
    }

    while (true) {
      final key =
          '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      final minutes = dailyMinutes[key] ?? 0;
      if (minutes >= threshold) {
        streak++;
        checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
      } else {
        break;
      }
    }

    return streak;
  }

  int calculateLongestStreak([int minMinutesPerDay = 1]) {
    final threshold = minMinutesPerDay > 0 ? minMinutesPerDay : 1;
    final sessions = getSessions();
    if (sessions.isEmpty) return 0;

    final Map<String, int> dailyMinutes = {};
    for (final s in sessions) {
      final dateKey =
          '${s.startTime.year}-${s.startTime.month.toString().padLeft(2, '0')}-${s.startTime.day.toString().padLeft(2, '0')}';
      dailyMinutes[dateKey] = (dailyMinutes[dateKey] ?? 0) + s.durationMinutes;
    }

    if (dailyMinutes.isEmpty) return 0;

    final sortedDates = dailyMinutes.keys.toList()..sort();
    int maxStreak = 0;
    int currentRun = 0;
    DateTime? prevDate;

    for (final dateStr in sortedDates) {
      final parts = dateStr.split('-');
      final date = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      final minutes = dailyMinutes[dateStr] ?? 0;

      if (minutes >= threshold) {
        if (prevDate == null) {
          currentRun = 1;
        } else {
          final expectedNext = DateTime(prevDate.year, prevDate.month, prevDate.day + 1);
          if (date.year == expectedNext.year &&
              date.month == expectedNext.month &&
              date.day == expectedNext.day) {
            currentRun++;
          } else {
            currentRun = 1;
          }
        }
        if (currentRun > maxStreak) {
          maxStreak = currentRun;
        }
        prevDate = date;
      } else {
        currentRun = 0;
        prevDate = null;
      }
    }

    return maxStreak;
  }

  Map<DateTime, int> getActivityMap() {
    final sessions = getSessions();
    final Map<DateTime, int> map = {};

    for (final s in sessions) {
      final dayKey = DateTime(s.startTime.year, s.startTime.month, s.startTime.day);
      map[dayKey] = (map[dayKey] ?? 0) + s.durationMinutes;
    }

    return map;
  }
}
