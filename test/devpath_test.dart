import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devpath/data/models/roadmap_models.dart';
import 'package:devpath/data/models/study_session.dart';
import 'package:devpath/data/models/project_model.dart';
import 'package:devpath/data/models/app_stats.dart';
import 'package:devpath/data/services/storage_service.dart';
import 'package:devpath/data/repositories/roadmap_repository.dart';
import 'package:devpath/data/repositories/study_session_repository.dart';
import 'package:devpath/data/repositories/project_repository.dart';
import 'package:devpath/data/repositories/notes_repository.dart';

void main() {
  group('1. Progress Calculation Tests', () {
    test('Calculates topic and month progress percentages correctly', () {
      const lesson1 = Lesson(
        id: 'l1',
        topicId: 't1',
        monthId: 'm1',
        title: 'L1',
        description: '',
        completed: true,
      );
      const lesson2 = Lesson(
        id: 'l2',
        topicId: 't1',
        monthId: 'm1',
        title: 'L2',
        description: '',
        completed: false,
      );

      final topic = Topic(
        id: 't1',
        monthId: 'm1',
        title: 'Topic 1',
        description: '',
        order: 1,
        lessons: [lesson1, lesson2],
      );

      expect(topic.completedLessonsCount, 1);
      expect(topic.progressPercentage, 50.0);

      final month = Month(
        id: 'm1',
        monthNumber: 1,
        title: 'Month 1',
        subtitle: '',
        description: '',
        order: 1,
        topics: [topic],
      );

      expect(month.totalLessonsCount, 2);
      expect(month.completedLessonsCount, 1);
      expect(month.progressPercentage, 50.0);
    });

    test('Pace message evaluates ahead, on track, and behind accurately', () {
      const statsAhead = AppStats(
        overallProgress: 30.0,
        expectedProgress: 20.0,
        totalLessons: 100,
        completedLessons: 30,
      );
      expect(statsAhead.isAheadOfPace, isTrue);
      expect(statsAhead.paceMessage, contains('ahead of your planned pace'));

      const statsOnTrack = AppStats(
        overallProgress: 21.0,
        expectedProgress: 20.0,
        totalLessons: 100,
        completedLessons: 21,
      );
      expect(statsOnTrack.paceMessage, contains('right on track'));

      const statsBehind = AppStats(
        overallProgress: 10.0,
        expectedProgress: 20.0,
        totalLessons: 100,
        completedLessons: 10,
      );
      expect(statsBehind.isAheadOfPace, isFalse);
      expect(statsBehind.paceMessage, contains('behind your planned pace'));
    });

    test('Zero lessons or empty topics do not produce NaN or Infinity', () {
      const emptyTopic = Topic(
        id: 't_empty',
        monthId: 'm1',
        title: 'Empty Topic',
        description: '',
        order: 1,
        lessons: [],
      );
      expect(emptyTopic.completedLessonsCount, 0);
      expect(emptyTopic.progressPercentage, 0.0);
      expect(emptyTopic.progressPercentage.isNaN, isFalse);

      const emptyMonth = Month(
        id: 'm_empty',
        monthNumber: 1,
        title: 'Empty Month',
        subtitle: '',
        description: '',
        order: 1,
        topics: [emptyTopic],
      );
      expect(emptyMonth.totalLessonsCount, 0);
      expect(emptyMonth.completedLessonsCount, 0);
      expect(emptyMonth.progressPercentage, 0.0);
      expect(emptyMonth.progressPercentage.isNaN, isFalse);
    });
  });

  group('2. Streak Calculation Tests', () {
    late StorageService storage;
    late StudySessionRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await StorageService.init();
      repo = StudySessionRepository(storage);
    });

    test('Computes current streak across consecutive days', () async {
      final now = DateTime.now();

      // Today's session
      final sessionToday = StudySession(
        id: 's1',
        lessonId: 'l1',
        lessonTitle: 'Python Variables',
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: now,
        durationMinutes: 30,
      );

      // Yesterday's session
      final yesterday = now.subtract(const Duration(days: 1));
      final sessionYesterday = StudySession(
        id: 's2',
        lessonId: 'l2',
        lessonTitle: 'Python Functions',
        startTime: yesterday.subtract(const Duration(minutes: 40)),
        endTime: yesterday,
        durationMinutes: 40,
      );

      await repo.recordSession(sessionToday);
      await repo.recordSession(sessionYesterday);

      final streak = repo.calculateCurrentStreak(15);
      expect(streak, 2);

      final longestStreak = repo.calculateLongestStreak(15);
      expect(longestStreak, 2);
    });

    test('Multiple sessions on the same day do not inflate streak count', () async {
      final now = DateTime.now();
      for (int i = 0; i < 5; i++) {
        await repo.recordSession(StudySession(
          id: 'multi_$i',
          lessonId: 'l1',
          lessonTitle: 'Multi Session',
          startTime: now.subtract(Duration(minutes: 60 * (i + 1))),
          endTime: now.subtract(Duration(minutes: 60 * i + 10)),
          durationMinutes: 50,
        ));
      }

      expect(repo.calculateCurrentStreak(1), 1);
      expect(repo.calculateLongestStreak(1), 1);
    });

    test('Skipped day breaks current streak but preserves longest streak', () async {
      final today = DateTime.now();
      final day3Ago = today.subtract(const Duration(days: 3));
      final day4Ago = today.subtract(const Duration(days: 4));
      final day5Ago = today.subtract(const Duration(days: 5));

      // 3 consecutive days in past
      await repo.recordSession(StudySession(
        id: 'p1',
        lessonId: 'l1',
        lessonTitle: 'L1',
        startTime: day5Ago,
        endTime: day5Ago.add(const Duration(minutes: 30)),
        durationMinutes: 30,
      ));
      await repo.recordSession(StudySession(
        id: 'p2',
        lessonId: 'l2',
        lessonTitle: 'L2',
        startTime: day4Ago,
        endTime: day4Ago.add(const Duration(minutes: 30)),
        durationMinutes: 30,
      ));
      await repo.recordSession(StudySession(
        id: 'p3',
        lessonId: 'l3',
        lessonTitle: 'L3',
        startTime: day3Ago,
        endTime: day3Ago.add(const Duration(minutes: 30)),
        durationMinutes: 30,
      ));

      // Today's session (with day 1 and 2 ago skipped)
      await repo.recordSession(StudySession(
        id: 'today',
        lessonId: 'l4',
        lessonTitle: 'L4',
        startTime: today,
        endTime: today.add(const Duration(minutes: 30)),
        durationMinutes: 30,
      ));

      expect(repo.calculateCurrentStreak(1), 1);
      expect(repo.calculateLongestStreak(1), 3);
    });

    test('Midnight boundary correctly counts as two consecutive days', () async {
      // Day 1 at 23:45
      final day1 = DateTime(2026, 5, 10, 23, 45);
      // Day 2 at 00:15
      final day2 = DateTime(2026, 5, 11, 0, 15);

      await repo.recordSession(StudySession(
        id: 'night1',
        lessonId: 'l1',
        lessonTitle: 'Late Study',
        startTime: day1,
        endTime: day1.add(const Duration(minutes: 15)),
        durationMinutes: 15,
      ));
      await repo.recordSession(StudySession(
        id: 'night2',
        lessonId: 'l2',
        lessonTitle: 'Early Study',
        startTime: day2,
        endTime: day2.add(const Duration(minutes: 15)),
        durationMinutes: 15,
      ));

      expect(repo.calculateLongestStreak(1), 2);
    });

    test('Aggregates total, weekly and monthly study minutes', () async {
      final now = DateTime.now();
      final session1 = StudySession(
        id: 's1',
        lessonId: 'l1',
        lessonTitle: 'Lesson 1',
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: now,
        durationMinutes: 30,
      );
      final session2 = StudySession(
        id: 's2',
        lessonId: 'l2',
        lessonTitle: 'Lesson 2',
        startTime: now.subtract(const Duration(minutes: 60)),
        endTime: now.subtract(const Duration(minutes: 30)),
        durationMinutes: 30,
      );

      await repo.recordSession(session1);
      await repo.recordSession(session2);

      expect(repo.getTotalStudyMinutes(), 60);
      expect(repo.getWeeklyStudyMinutes(), 60);
      expect(repo.getMonthlyStudyMinutes(), 60);
    });
  });

  group('3. Daily Plan Generation Tests', () {
    late StorageService storage;
    late RoadmapRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await StorageService.init();
      repo = RoadmapRepository(storage);
    });

    test('Picks first incomplete lessons up to daily goal', () {
      final plan = repo.getTodaysPlan(60);
      expect(plan, isNotEmpty);
      expect(plan.every((l) => !l.completed), isTrue);

      final firstIncomplete = repo.getFirstIncompleteLesson();
      expect(firstIncomplete, isNotNull);
      expect(plan.first.id, firstIncomplete!.id);
    });

    test('Automatically advances plan when lesson completed', () async {
      final initialPlan = repo.getTodaysPlan(60);
      final firstLessonId = initialPlan.first.id;

      await repo.toggleLessonCompletion(firstLessonId, true);

      final updatedPlan = repo.getTodaysPlan(60);
      expect(updatedPlan.any((l) => l.id == firstLessonId), isFalse);
    });
  });

  group('4. Project Progress Tests', () {
    late StorageService storage;
    late ProjectRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await StorageService.init();
      repo = ProjectRepository(storage);
    });

    test('Automatically calculates project progress from tasks', () async {
      final projects = repo.getProjects();
      expect(projects, isNotEmpty);
      final project = projects.first;
      final initialProgress = project.progressPercentage;
      expect(initialProgress, 0.0);

      final firstTaskId = project.tasks.first.id;
      await repo.toggleTask(project.id, firstTaskId, true);

      final updated = repo.getProjectById(project.id)!;
      expect(updated.completedTasksCount, 1);
      expect(updated.progressPercentage, greaterThan(0.0));
      expect(updated.isCompleted, isFalse);
    });

    test('Marks project complete when all tasks checked', () {
      const task1 = ProjectTask(id: 't1', title: 'T1', completed: true);
      const task2 = ProjectTask(id: 't2', title: 'T2', completed: true);

      const p = Project(
        id: 'p1',
        monthNumber: 1,
        title: 'Project 1',
        description: '',
        technologies: ['Dart'],
        tasks: [task1, task2],
      );

      expect(p.progressPercentage, 100.0);
      expect(p.isCompleted, isTrue);
    });

    test('Project with zero tasks handles progress calculation safely', () {
      const emptyProject = Project(
        id: 'p_empty',
        monthNumber: 1,
        title: 'Empty Project',
        description: '',
        technologies: [],
        tasks: [],
      );

      expect(emptyProject.progressPercentage, 0.0);
      expect(emptyProject.progressPercentage.isNaN, isFalse);
      expect(emptyProject.isCompleted, isFalse);
    });
  });

  group('5. Data Persistence & Backup Tests', () {
    test('Exports and imports entire backup JSON seamlessly', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();

      // Modify profile
      final currentProfile = storage.getProfile();
      await storage.saveProfile(currentProfile.copyWith(name: 'Dev Hero'));

      final jsonBackup = storage.exportAllDataJson();
      expect(jsonBackup, contains('Dev Hero'));
      expect(jsonBackup, contains('curriculum'));
      expect(jsonBackup, contains('projects'));

      // Test import
      final success = await storage.importDataJson(jsonBackup);
      expect(success, isTrue);
      expect(storage.getProfile().name, 'Dev Hero');
    });

    test('Safely rejects invalid, empty, or corrupted backup JSON without mutating data', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();

      final originalProfile = storage.getProfile();

      // Empty string
      final resEmpty = await storage.importDataJson('');
      expect(resEmpty, isFalse);

      // Malformed JSON syntax
      final resBroken = await storage.importDataJson('{invalid_json: 123');
      expect(resBroken, isFalse);

      // Corrupted schema (missing required profile object)
      final resBadSchema = await storage.importDataJson('{"foo": "bar"}');
      expect(resBadSchema, isFalse);

      // Verify original profile was not wiped or corrupted
      expect(storage.getProfile().name, originalProfile.name);
    });

    test('Resets all progress cleanly without corrupting user profile', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();

      await storage.resetAllProgress();

      final curriculum = storage.getCurriculum();
      final allLessons = curriculum.expand((m) => m.allLessons);
      expect(allLessons.every((l) => !l.completed), isTrue);

      final sessions = storage.getStudySessions();
      expect(sessions, isEmpty);
    });
  });

  group('6. Notes Repository Tests', () {
    late StorageService storage;
    late NotesRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await StorageService.init();
      repo = NotesRepository(storage);
    });

    test('Handles special characters, emojis, HTML, and unknown ID insertion', () async {
      final initialNotes = repo.getNotes();
      expect(initialNotes, isEmpty);

      // Test insertion with special characters & emojis
      const specialTitle = 'Note with <script> & "quotes" / \\';
      const specialContent = 'Multi-line\nSpecial: < > & " \' / \\\nEmoji: 🚀🎉🔥';

      // Save with new non-existent ID
      final createdNote = await repo.saveNote(
        id: 'new_unknown_id_1',
        lessonId: 'l1',
        lessonTitle: 'Intro',
        title: specialTitle,
        content: specialContent,
      );

      expect(createdNote.id, 'new_unknown_id_1');
      expect(createdNote.title, specialTitle);
      expect(createdNote.content, specialContent);

      final retrieved = repo.getNotes();
      expect(retrieved.length, 1);
      expect(retrieved.first.content, contains('🚀🎉🔥'));

      // Test editing existing note
      final updatedNote = await repo.saveNote(
        id: 'new_unknown_id_1',
        lessonId: 'l1',
        lessonTitle: 'Intro',
        title: 'Updated Title',
        content: 'Updated Content',
      );
      expect(updatedNote.title, 'Updated Title');
      expect(repo.getNotes().length, 1);
      expect(repo.getNotes().first.title, 'Updated Title');

      // Test delete
      await repo.deleteNote('new_unknown_id_1');
      expect(repo.getNotes(), isEmpty);
    });
  });
}
