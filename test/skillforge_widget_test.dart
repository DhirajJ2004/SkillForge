import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devpath/data/models/app_stats.dart';
import 'package:devpath/data/models/roadmap_models.dart';
import 'package:devpath/data/models/user_profile.dart';
import 'package:devpath/features/dashboard/widgets/greeting_header.dart';
import 'package:devpath/features/dashboard/widgets/quick_stats_row.dart';
import 'package:devpath/features/dashboard/widgets/todays_goal_card.dart';
import 'package:devpath/features/dashboard/widgets/todays_plan_card.dart';
import 'package:devpath/features/roadmap/widgets/interactive_roadmap_tree.dart';
import 'package:devpath/features/roadmap/widgets/month_accordion.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  group('SkillForge Dashboard Widget Tests', () {
    testWidgets('GreetingHeader displays learner greeting and user name', (tester) async {
      final user = UserProfile(
        id: 'u_test',
        name: 'Alex',
        dailyGoalMinutes: 45,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(createTestWidget(GreetingHeader(user: user)));
      await tester.pump();

      expect(find.textContaining('Alex'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('QuickStatsRow renders streak, study time, and completed count', (tester) async {
      const stats = AppStats(
        currentStreak: 12,
        totalStudyMinutes: 180,
        completedLessons: 24,
        totalLessons: 100,
        overallProgress: 24.0,
      );

      await tester.pumpWidget(createTestWidget(const QuickStatsRow(stats: stats)));
      await tester.pump();

      expect(find.text('12d'), findsOneWidget);
      expect(find.text('3.0h'), findsOneWidget);
      expect(find.text('24'), findsOneWidget);
      expect(find.text('Day Streak'), findsOneWidget);
      expect(find.text('Study Time'), findsOneWidget);
    });

    testWidgets('TodaysGoalCard renders progress and target correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const TodaysGoalCard(
          todayMinutes: 40,
          goalMinutes: 60,
        ),
      ));
      await tester.pump();

      expect(find.text("TODAY'S GOAL"), findsOneWidget);
      expect(find.text('40 / 60 min (66%)'), findsOneWidget);
      expect(find.text('20 min remaining to complete today\'s goal'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('TodaysPlanCard displays lessons and checkbox interactions', (tester) async {
      const lesson1 = Lesson(
        id: 'plan_l1',
        topicId: 't1',
        monthId: 'm1',
        title: 'Variables and Memory in Python',
        description: '',
        estimatedMinutes: 20,
        completed: false,
      );

      await tester.pumpWidget(createTestWidget(
        const TodaysPlanCard(plan: [lesson1]),
      ));
      await tester.pump();

      expect(find.text("TODAY'S PLAN"), findsOneWidget);
      expect(find.text('Variables and Memory in Python'), findsOneWidget);
      expect(find.text('20 min'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsOneWidget);
    });
  });

  group('SkillForge Roadmap Widget Tests', () {
    testWidgets('InteractiveRoadmapTree displays stages and status badges', (tester) async {
      final month1 = Month(
        id: 'm1',
        monthNumber: 1,
        title: 'Python Mastery',
        subtitle: 'Foundations of programming',
        description: '',
        order: 1,
        topics: [
          Topic(
            id: 't1',
            monthId: 'm1',
            title: 'OOP Concepts',
            description: '',
            order: 1,
            lessons: [
              const Lesson(id: 'l1', topicId: 't1', monthId: 'm1', title: 'Classes', description: '', completed: true),
            ],
          ),
        ],
      );

      await tester.pumpWidget(createTestWidget(
        InteractiveRoadmapTree(curriculum: [month1]),
      ));
      await tester.pump();

      expect(find.text('STAGE 1'), findsOneWidget);
      expect(find.text('Python Mastery'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('OOP Concepts'), findsOneWidget);
    });

    testWidgets('MonthAccordion expands and displays topics correctly', (tester) async {
      final month = Month(
        id: 'm2',
        monthNumber: 2,
        title: 'Frontend Foundations',
        subtitle: 'Modern web layout and DOM',
        description: '',
        order: 2,
        topics: [
          Topic(
            id: 't_html',
            monthId: 'm2',
            title: 'Semantic HTML & CSS',
            description: '',
            order: 1,
            lessons: [
              const Lesson(id: 'l_html_1', topicId: 't_html', monthId: 'm2', title: 'Tags & Flexbox', description: '', completed: false),
            ],
          ),
        ],
      );

      await tester.pumpWidget(createTestWidget(
        MonthAccordion(month: month, initialExpanded: true),
      ));
      await tester.pump();

      expect(find.text('STAGE 2'), findsOneWidget);
      expect(find.text('Frontend Foundations'), findsOneWidget);
      expect(find.text('Semantic HTML & CSS'), findsOneWidget);
      expect(find.text('Tags & Flexbox'), findsOneWidget);
    });
  });
}
