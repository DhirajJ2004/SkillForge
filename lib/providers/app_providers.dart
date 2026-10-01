import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_profile.dart';
import '../data/models/roadmap_models.dart';
import '../data/models/study_session.dart';
import '../data/models/project_model.dart';
import '../data/models/note_model.dart';
import '../data/models/app_stats.dart';
import '../data/models/practice_model.dart';
import '../data/models/achievement_model.dart';
import '../data/services/storage_service.dart';
import '../data/services/notification_service.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/roadmap_repository.dart';
import '../data/repositories/study_session_repository.dart';
import '../data/repositories/project_repository.dart';
import '../data/repositories/notes_repository.dart';
import '../data/repositories/practice_repository.dart';

// Services
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be overridden in ProviderScope');
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Repositories
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(storageServiceProvider));
});

final roadmapRepositoryProvider = Provider<RoadmapRepository>((ref) {
  return RoadmapRepository(ref.watch(storageServiceProvider));
});

final studySessionRepositoryProvider = Provider<StudySessionRepository>((ref) {
  return StudySessionRepository(ref.watch(storageServiceProvider));
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(ref.watch(storageServiceProvider));
});

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository(ref.watch(storageServiceProvider));
});

final practiceRepositoryProvider = Provider<PracticeRepository>((ref) {
  return PracticeRepository(ref.watch(storageServiceProvider));
});

// Theme Mode Notifier
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final storage = ref.watch(storageServiceProvider);
    final mode = storage.getThemeMode();
    if (mode == 'light') return ThemeMode.light;
    if (mode == 'system') return ThemeMode.system;
    return ThemeMode.dark;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final str = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.system
            ? 'system'
            : 'dark';
    await ref.read(storageServiceProvider).saveThemeMode(str);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

// User Profile Notifier
class UserProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    return ref.watch(userRepositoryProvider).getProfile();
  }

  Future<void> updateProfile(UserProfile profile) async {
    await ref.read(userRepositoryProvider).updateProfile(profile);
    state = profile;
  }

  Future<void> completeOnboarding({
    required String name,
    required int dailyGoalMinutes,
    required int preferredStudyTimeHour,
    required int preferredStudyTimeMinute,
    required List<int> studyDays,
  }) async {
    await ref.read(userRepositoryProvider).completeOnboarding(
      name: name,
      dailyGoalMinutes: dailyGoalMinutes,
      preferredStudyTimeHour: preferredStudyTimeHour,
      preferredStudyTimeMinute: preferredStudyTimeMinute,
      studyDays: studyDays,
    );
    state = ref.read(userRepositoryProvider).getProfile();
  }

  void refresh() {
    state = ref.read(userRepositoryProvider).getProfile();
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfile>(UserProfileNotifier.new);

// Curriculum Notifier
class CurriculumNotifier extends Notifier<List<Month>> {
  @override
  List<Month> build() {
    return ref.watch(roadmapRepositoryProvider).getCurriculum();
  }

  Future<void> toggleLesson(String lessonId, bool completed) async {
    await ref.read(roadmapRepositoryProvider).toggleLessonCompletion(lessonId, completed);
    state = ref.read(roadmapRepositoryProvider).getCurriculum();
  }

  Future<void> toggleBookmark(String lessonId, bool isBookmarked) async {
    await ref.read(roadmapRepositoryProvider).toggleLessonBookmark(lessonId, isBookmarked);
    state = ref.read(roadmapRepositoryProvider).getCurriculum();
  }

  Future<void> markResourceOpened(String lessonId, String resourceId) async {
    await ref.read(roadmapRepositoryProvider).markResourceOpened(lessonId, resourceId);
    state = ref.read(roadmapRepositoryProvider).getCurriculum();
  }

  void refresh() {
    state = ref.read(roadmapRepositoryProvider).getCurriculum();
  }
}

final curriculumProvider =
    NotifierProvider<CurriculumNotifier, List<Month>>(CurriculumNotifier.new);

// Bookmarked Lessons Provider
final bookmarkedLessonsProvider = Provider<List<Lesson>>((ref) {
  final curriculum = ref.watch(curriculumProvider);
  final List<Lesson> bookmarks = [];
  for (final m in curriculum) {
    for (final t in m.topics) {
      for (final l in t.lessons) {
        if (l.isBookmarked) {
          bookmarks.add(l);
        }
      }
    }
  }
  return bookmarks;
});

// Current Focus Lesson (first incomplete lesson)
final currentFocusLessonProvider = Provider<Lesson?>((ref) {
  final curriculum = ref.watch(curriculumProvider);
  for (final month in curriculum) {
    for (final topic in month.topics) {
      for (final lesson in topic.lessons) {
        if (!lesson.completed) {
          return lesson;
        }
      }
    }
  }
  return null;
});

// Today's Plan Provider
final todaysPlanProvider = Provider<List<Lesson>>((ref) {
  final curriculum = ref.watch(curriculumProvider);
  final user = ref.watch(userProfileProvider);
  final List<Lesson> plan = [];
  int totalMinutes = 0;

  for (final month in curriculum) {
    for (final topic in month.topics) {
      for (final lesson in topic.lessons) {
        if (!lesson.completed) {
          plan.add(lesson);
          totalMinutes += lesson.estimatedMinutes;
          if (totalMinutes >= user.dailyGoalMinutes && plan.length >= 2) {
            return plan;
          }
          if (plan.length >= 4) {
            return plan;
          }
        }
      }
    }
  }
  return plan;
});

// Today's Study Minutes Provider
final todayStudyMinutesProvider = Provider<int>((ref) {
  ref.watch(studySessionsProvider);
  return ref.watch(studySessionRepositoryProvider).getTodayStudyMinutes();
});

// Projects Notifier
class ProjectsNotifier extends Notifier<List<Project>> {
  @override
  List<Project> build() {
    return ref.watch(projectRepositoryProvider).getProjects();
  }

  Future<void> toggleTask(String projectId, String taskId, bool completed) async {
    await ref.read(projectRepositoryProvider).toggleTask(projectId, taskId, completed);
    state = ref.read(projectRepositoryProvider).getProjects();
  }

  Future<void> updateProjectDetails({
    required String projectId,
    required String githubUrl,
    required String liveUrl,
    required String notes,
  }) async {
    await ref.read(projectRepositoryProvider).updateProjectUrlsAndNotes(
      projectId: projectId,
      githubUrl: githubUrl,
      liveUrl: liveUrl,
      notes: notes,
    );
    state = ref.read(projectRepositoryProvider).getProjects();
  }

  void refresh() {
    state = ref.read(projectRepositoryProvider).getProjects();
  }
}

final projectsProvider =
    NotifierProvider<ProjectsNotifier, List<Project>>(ProjectsNotifier.new);

// Notes Notifier
class NotesNotifier extends Notifier<List<Note>> {
  @override
  List<Note> build() {
    return ref.watch(notesRepositoryProvider).getNotes();
  }

  Future<Note> saveNote({
    String? id,
    required String lessonId,
    required String lessonTitle,
    required String title,
    required String content,
  }) async {
    final note = await ref.read(notesRepositoryProvider).saveNote(
      id: id,
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      title: title,
      content: content,
    );
    state = ref.read(notesRepositoryProvider).getNotes();
    return note;
  }

  Future<void> deleteNote(String id) async {
    await ref.read(notesRepositoryProvider).deleteNote(id);
    state = ref.read(notesRepositoryProvider).getNotes();
  }

  void refresh() {
    state = ref.read(notesRepositoryProvider).getNotes();
  }
}

final notesProvider =
    NotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

// Study Sessions Notifier
class StudySessionsNotifier extends Notifier<List<StudySession>> {
  @override
  List<StudySession> build() {
    return ref.watch(studySessionRepositoryProvider).getSessions();
  }

  Future<void> recordSession(StudySession session) async {
    await ref.read(studySessionRepositoryProvider).recordSession(session);
    state = ref.read(studySessionRepositoryProvider).getSessions();
  }

  void refresh() {
    state = ref.read(studySessionRepositoryProvider).getSessions();
  }
}

final studySessionsProvider =
    NotifierProvider<StudySessionsNotifier, List<StudySession>>(StudySessionsNotifier.new);

// App Stats Provider (Overall Progress, Streak, Study Hours, Projects, Velocity)
final appStatsProvider = Provider<AppStats>((ref) {
  final curriculum = ref.watch(curriculumProvider);
  // observe sessions for reactivity
  ref.watch(studySessionsProvider);
  final projects = ref.watch(projectsProvider);
  final user = ref.watch(userProfileProvider);
  final sessionRepo = ref.watch(studySessionRepositoryProvider);

  // Lesson counts
  int totalLessons = 0;
  int completedLessons = 0;
  for (final m in curriculum) {
    for (final t in m.topics) {
      for (final l in t.lessons) {
        totalLessons++;
        if (l.completed) completedLessons++;
      }
    }
  }

  final double overallProgress = totalLessons > 0
      ? ((completedLessons / totalLessons) * 100).clamp(0.0, 100.0)
      : 0.0;

  // Streak (counts any day with recorded study session)
  final int currentStreak = sessionRepo.calculateCurrentStreak(1);
  final int longestStreak = sessionRepo.calculateLongestStreak(1);

  final int totalStudyMinutes = sessionRepo.getTotalStudyMinutes();
  final int weeklyStudyMinutes = sessionRepo.getWeeklyStudyMinutes();
  final int monthlyStudyMinutes = sessionRepo.getMonthlyStudyMinutes();
  final int studyDaysThisWeek = sessionRepo.getStudyDaysThisWeek();

  final int completedProjects = projects.where((p) => p.isCompleted).length;

  // Expected progress calculation based on calendar days:
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final createdDate = DateTime(user.createdAt.year, user.createdAt.month, user.createdAt.day);
  final daysSinceStart = today.difference(createdDate).inDays.clamp(0, 180);
  final expectedProgress = ((daysSinceStart / 180.0) * 100).clamp(0.0, 100.0);

  return AppStats(
    overallProgress: overallProgress,
    completedLessons: completedLessons,
    totalLessons: totalLessons,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    totalStudyMinutes: totalStudyMinutes,
    weeklyStudyMinutes: weeklyStudyMinutes,
    monthlyStudyMinutes: monthlyStudyMinutes,
    studyDaysThisWeek: studyDaysThisWeek,
    completedProjects: completedProjects,
    totalProjects: projects.length,
    expectedProgress: expectedProgress,
  );
});

// Practice Attempts Notifier & Provider
class PracticeAttemptsNotifier extends Notifier<List<PracticeAttempt>> {
  @override
  List<PracticeAttempt> build() {
    return ref.watch(practiceRepositoryProvider).getAttempts();
  }

  Future<void> recordAttempt(PracticeAttempt attempt) async {
    await ref.read(practiceRepositoryProvider).recordAttempt(attempt);
    state = ref.read(practiceRepositoryProvider).getAttempts();
  }

  void refresh() {
    state = ref.read(practiceRepositoryProvider).getAttempts();
  }
}

final practiceAttemptsProvider =
    NotifierProvider<PracticeAttemptsNotifier, List<PracticeAttempt>>(PracticeAttemptsNotifier.new);

final practiceStatsProvider = Provider<PracticeStatsSummary>((ref) {
  final attempts = ref.watch(practiceAttemptsProvider);
  return PracticeStatsSummary.fromAttempts(attempts);
});

// Deterministic User XP Provider
final userXPProvider = Provider<UserXP>((ref) {
  final stats = ref.watch(appStatsProvider);
  final projects = ref.watch(projectsProvider);
  final practiceStats = ref.watch(practiceStatsProvider);
  final curriculum = ref.watch(curriculumProvider);

  int completedTasks = 0;
  for (final p in projects) {
    completedTasks += p.completedTasksCount;
  }

  int completedCourses = 0;
  for (final m in curriculum) {
    if (m.progressPercentage >= 100.0) {
      completedCourses++;
    }
  }

  return UserXP.calculate(
    completedLessons: stats.completedLessons,
    completedProjects: stats.completedProjects,
    completedTasks: completedTasks,
    currentStreak: stats.currentStreak,
    totalStudyMinutes: stats.totalStudyMinutes,
    quizQuestionsCorrect: practiceStats.totalCorrectAnswers,
    completedCourses: completedCourses,
  );
});

// Deterministic Achievements Provider
final achievementsProvider = Provider<List<Achievement>>((ref) {
  final stats = ref.watch(appStatsProvider);
  final practiceStats = ref.watch(practiceStatsProvider);
  final practiceRepo = ref.watch(practiceRepositoryProvider);
  final curriculum = ref.watch(curriculumProvider);

  int completedCourses = 0;
  for (final m in curriculum) {
    if (m.progressPercentage >= 100.0) {
      completedCourses++;
    }
  }

  return AchievementEngine.evaluate(
    completedLessons: stats.completedLessons,
    completedProjects: stats.completedProjects,
    completedCourses: completedCourses,
    streakDays: stats.currentStreak > stats.longestStreak
        ? stats.currentStreak
        : stats.longestStreak,
    totalStudyMinutes: stats.totalStudyMinutes,
    totalQuizQuestionsAttempted: practiceStats.totalQuestionsAttempted,
    highestQuizAccuracy: practiceRepo.getHighestAccuracy(),
  );
});
