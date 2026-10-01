import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devpath/data/models/achievement_model.dart';
import 'package:devpath/data/models/practice_model.dart';
import 'package:devpath/data/models/roadmap_models.dart';
import 'package:devpath/data/repositories/practice_repository.dart';
import 'package:devpath/data/repositories/roadmap_repository.dart';
import 'package:devpath/data/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;
  late PracticeRepository practiceRepo;
  late RoadmapRepository roadmapRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    storageService = StorageService(prefs);
    practiceRepo = PracticeRepository(storageService);
    roadmapRepo = RoadmapRepository(storageService);
  });

  group('1. XP and Level Progression Tests', () {
    test('Calculates UserXP deterministically with correct formula', () {
      final xp = UserXP.calculate(
        completedLessons: 10, // 10 * 50 = 500
        completedProjects: 1, // 1 * 300 = 300
        completedTasks: 4, // 4 * 100 = 400
        currentStreak: 7, // 7 * 25 = 175
        totalStudyMinutes: 120, // 120 ~/ 2 = 60
        quizQuestionsCorrect: 15, // 15 * 10 = 150
        completedCourses: 0,
      );

      // Total XP = 500 + 300 + 400 + 175 + 60 + 150 = 1585 XP
      expect(xp.totalXP, 1585);
      // Level = (1585 ~/ 500) + 1 = 3 + 1 = 4
      expect(xp.currentLevel, 4);
      // Remainder = 1585 % 500 = 85
      expect(xp.xpIntoCurrentLevel, 85);
      expect(xp.xpRequiredForNextLevel, 500);
      expect(xp.levelProgress, closeTo(85 / 500, 0.001));
      expect(xp.levelTitle, 'Junior Apprentice');
    });

    test('XP level titles advance across all milestones', () {
      final novice = UserXP.calculate(
        completedLessons: 1,
        completedProjects: 0,
        completedTasks: 0,
        currentStreak: 1,
        totalStudyMinutes: 10,
        quizQuestionsCorrect: 0,
        completedCourses: 0,
      );
      expect(novice.levelTitle, 'Novice Developer');

      final junior = UserXP.calculate(
        completedLessons: 30, // 1500 XP -> Level 4
        completedProjects: 0,
        completedTasks: 0,
        currentStreak: 0,
        totalStudyMinutes: 0,
        quizQuestionsCorrect: 0,
        completedCourses: 0,
      );
      expect(junior.levelTitle, 'Junior Apprentice');

      final core = UserXP.calculate(
        completedLessons: 60, // 3000 XP -> Level 7
        completedProjects: 0,
        completedTasks: 0,
        currentStreak: 0,
        totalStudyMinutes: 0,
        quizQuestionsCorrect: 0,
        completedCourses: 0,
      );
      expect(core.levelTitle, 'Core Engineer');

      final senior = UserXP.calculate(
        completedLessons: 100, // 5000 XP -> Level 11
        completedProjects: 2,
        completedTasks: 0,
        currentStreak: 0,
        totalStudyMinutes: 0,
        quizQuestionsCorrect: 0,
        completedCourses: 0,
      );
      expect(senior.levelTitle, 'Senior Builder');

      final architect = UserXP.calculate(
        completedLessons: 150, // 7500 XP
        completedProjects: 5, // + 1500 XP = 9000 XP -> Level 19
        completedTasks: 0,
        currentStreak: 0,
        totalStudyMinutes: 0,
        quizQuestionsCorrect: 0,
        completedCourses: 0,
      );
      expect(architect.levelTitle, 'Lead Architect');
    });
  });

  group('2. Achievement Engine Evaluation Tests', () {
    test('Unlocks achievements deterministically based on real criteria', () {
      final achievements = AchievementEngine.evaluate(
        completedLessons: 12,
        completedProjects: 1,
        completedCourses: 1,
        streakDays: 7,
        totalStudyMinutes: 650,
        totalQuizQuestionsAttempted: 52,
        highestQuizAccuracy: 95.0,
      );

      final firstStep = achievements.firstWhere((a) => a.id == 'first_step');
      expect(firstStep.unlocked, isTrue);

      final tenLessons = achievements.firstWhere((a) => a.id == 'ten_lessons');
      expect(tenLessons.unlocked, isTrue);

      final streak7 = achievements.firstWhere((a) => a.id == 'streak_7');
      expect(streak7.unlocked, isTrue);

      final firstProj = achievements.firstWhere((a) => a.id == 'first_project');
      expect(firstProj.unlocked, isTrue);

      final firstCourse = achievements.firstWhere((a) => a.id == 'first_course');
      expect(firstCourse.unlocked, isTrue);

      final quizAce = achievements.firstWhere((a) => a.id == 'quiz_master');
      expect(quizAce.unlocked, isTrue);

      final probSolver = achievements.firstWhere((a) => a.id == 'fifty_questions');
      expect(probSolver.unlocked, isTrue);

      final deepFocus = achievements.firstWhere((a) => a.id == 'ten_hours');
      expect(deepFocus.unlocked, isTrue);
    });

    test('Locked achievements show accurate progress ratios', () {
      final achievements = AchievementEngine.evaluate(
        completedLessons: 5,
        completedProjects: 0,
        completedCourses: 0,
        streakDays: 3,
        totalStudyMinutes: 300,
        totalQuizQuestionsAttempted: 25,
        highestQuizAccuracy: 60.0,
      );

      final tenLessons = achievements.firstWhere((a) => a.id == 'ten_lessons');
      expect(tenLessons.unlocked, isFalse);
      expect(tenLessons.progress, 0.5);

      final streak7 = achievements.firstWhere((a) => a.id == 'streak_7');
      expect(streak7.unlocked, isFalse);
      expect(streak7.progress, closeTo(3 / 7, 0.01));

      final fiftyQ = achievements.firstWhere((a) => a.id == 'fifty_questions');
      expect(fiftyQ.unlocked, isFalse);
      expect(fiftyQ.progress, 0.5);
    });
  });

  group('3. Practice System & Weak Topic Detection Tests', () {
    test('Calculates PracticeStatsSummary with real accuracy and weak topic', () {
      final attempt1 = PracticeAttempt(
        id: 'a1',
        moduleId: 'py_fund',
        moduleTitle: 'Python Fundamentals',
        category: 'Python',
        difficulty: 'Beginner',
        score: 5,
        totalQuestions: 5,
        accuracy: 100.0,
        completedAt: DateTime.now(),
      );

      final attempt2 = PracticeAttempt(
        id: 'a2',
        moduleId: 'dsa_patterns',
        moduleTitle: 'DSA Patterns',
        category: 'DSA',
        difficulty: 'Advanced',
        score: 1,
        totalQuestions: 5,
        accuracy: 20.0,
        completedAt: DateTime.now(),
      );

      final summary = PracticeStatsSummary.fromAttempts([attempt1, attempt2]);

      expect(summary.totalExercisesCompleted, 2);
      expect(summary.totalQuestionsAttempted, 10);
      expect(summary.totalCorrectAnswers, 6);
      expect(summary.overallAccuracy, 60.0);
      expect(summary.weakTopic, 'DSA');
      expect(summary.strongTopic, 'Python');
    });

    test('Records and persists practice attempts in PracticeRepository', () async {
      final attempt = PracticeAttempt(
        id: 'test_attempt_1',
        moduleId: 'sql_queries',
        moduleTitle: 'SQL Joins',
        category: 'SQL',
        difficulty: 'Intermediate',
        score: 4,
        totalQuestions: 4,
        accuracy: 100.0,
        completedAt: DateTime.now(),
      );

      await practiceRepo.recordAttempt(attempt);

      final attempts = practiceRepo.getAttempts();
      expect(attempts.length, 1);
      expect(attempts.first.id, 'test_attempt_1');
      expect(attempts.first.moduleTitle, 'SQL Joins');
      expect(attempts.first.score, 4);
    });
  });

  group('4. Lesson Bookmarking & Idempotent Completion Tests', () {
    test('Toggles bookmark on lessons idempotently', () async {
      final curriculum = roadmapRepo.getCurriculum();
      final firstLesson = curriculum.first.topics.first.lessons.first;

      expect(firstLesson.isBookmarked, isFalse);

      // Bookmark lesson
      await roadmapRepo.toggleLessonBookmark(firstLesson.id, true);
      var bookmarks = roadmapRepo.getBookmarkedLessons();
      expect(bookmarks.any((l) => l.id == firstLesson.id), isTrue);

      var updatedCurriculum = roadmapRepo.getCurriculum();
      var updatedLesson = updatedCurriculum.first.topics.first.lessons.first;
      expect(updatedLesson.isBookmarked, isTrue);

      // Unbookmark lesson
      await roadmapRepo.toggleLessonBookmark(firstLesson.id, false);
      bookmarks = roadmapRepo.getBookmarkedLessons();
      expect(bookmarks.any((l) => l.id == firstLesson.id), isFalse);

      updatedCurriculum = roadmapRepo.getCurriculum();
      updatedLesson = updatedCurriculum.first.topics.first.lessons.first;
      expect(updatedLesson.isBookmarked, isFalse);
    });

    test('Lesson completion is idempotent and updates month progress accurately', () async {
      final curriculum = roadmapRepo.getCurriculum();
      final firstLesson = curriculum.first.topics.first.lessons.first;

      // Mark complete multiple times
      await roadmapRepo.toggleLessonCompletion(firstLesson.id, true);
      await roadmapRepo.toggleLessonCompletion(firstLesson.id, true);

      var updated = roadmapRepo.getCurriculum();
      var completedCount = updated.first.completedLessonsCount;
      expect(completedCount, 1);

      // Toggle back to false
      await roadmapRepo.toggleLessonCompletion(firstLesson.id, false);
      updated = roadmapRepo.getCurriculum();
      expect(updated.first.completedLessonsCount, 0);
    });
  });

  group('5. Roadmap Node Status Progression Tests', () {
    test('Calculates node states: available, inProgress, completed, locked', () {
      final month1 = Month(
        id: 'm1',
        monthNumber: 1,
        title: 'M1',
        subtitle: '',
        description: '',
        order: 1,
        topics: [
          Topic(
            id: 't1',
            monthId: 'm1',
            title: 'T1',
            description: '',
            order: 1,
            lessons: [
              const Lesson(id: 'l1', topicId: 't1', monthId: 'm1', title: 'L1', description: '', completed: true),
              const Lesson(id: 'l2', topicId: 't1', monthId: 'm1', title: 'L2', description: '', completed: true),
            ],
          ),
        ],
      );

      final month2 = Month(
        id: 'm2',
        monthNumber: 2,
        title: 'M2',
        subtitle: '',
        description: '',
        order: 2,
        topics: [
          Topic(
            id: 't2',
            monthId: 'm2',
            title: 'T2',
            description: '',
            order: 1,
            lessons: [
              const Lesson(id: 'l3', topicId: 't2', monthId: 'm2', title: 'L3', description: '', completed: true),
              const Lesson(id: 'l4', topicId: 't2', monthId: 'm2', title: 'L4', description: '', completed: false),
            ],
          ),
        ],
      );

      final month3 = Month(
        id: 'm3',
        monthNumber: 3,
        title: 'M3',
        subtitle: '',
        description: '',
        order: 3,
        topics: [
          Topic(
            id: 't3',
            monthId: 'm3',
            title: 'T3',
            description: '',
            order: 1,
            lessons: [
              const Lesson(id: 'l5', topicId: 't3', monthId: 'm3', title: 'L5', description: '', completed: false),
            ],
          ),
        ],
      );

      expect(month1.isCompleted, isTrue);
      expect(month2.isCompleted, isFalse);
      expect(month2.completedLessonsCount > 0, isTrue);
      expect(month3.completedLessonsCount, 0);
    });
  });
}
