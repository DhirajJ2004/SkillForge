import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../features/common/widgets/app_scaffold.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/learn/screens/learn_screen.dart';
import '../../features/my_learning/screens/my_learning_screen.dart';
import '../../features/course/screens/course_detail_screen.dart';
import '../../features/practice/screens/practice_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/roadmap/screens/lesson_detail_screen.dart';
import '../../features/study/screens/study_session_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
import '../../features/resources/screens/resources_screen.dart';
import '../../features/projects/screens/projects_screen.dart';
import '../../features/projects/screens/project_detail_screen.dart';
import '../../features/notes/screens/notes_screen.dart';
import '../../features/notes/screens/note_editor_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/search/screens/global_search_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(userProfileProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: user.isOnboarded ? '/dashboard' : '/onboarding',
    redirect: (context, state) {
      final isOnboarded = user.isOnboarded;
      final isGoingToOnboarding = state.matchedLocation == '/onboarding';

      if (!isOnboarded && !isGoingToOnboarding) {
        return '/onboarding';
      }
      if (isOnboarded && isGoingToOnboarding) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Stateful Shell for Bottom Navigation Tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Tab 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Tab 1: Learn
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learn',
                builder: (context, state) => const LearnScreen(),
              ),
              GoRoute(
                path: '/roadmap',
                builder: (context, state) => const LearnScreen(),
              ),
            ],
          ),

          // Tab 2: My Learning
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-learning',
                builder: (context, state) => const MyLearningScreen(),
              ),
            ],
          ),

          // Tab 3: Progress
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),

          // Tab 4: Profile & Learning Hub
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
              GoRoute(
                path: '/more',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Detail & Modal Routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/lesson/:id',
        builder: (context, state) {
          final lessonId = state.pathParameters['id'] ?? '';
          return LessonDetailScreen(lessonId: lessonId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/study-session',
        builder: (context, state) {
          final lessonId = state.uri.queryParameters['lessonId'];
          final title = state.uri.queryParameters['title'];
          final durationStr = state.uri.queryParameters['duration'];
          final duration = int.tryParse(durationStr ?? '') ?? 30;

          return StudySessionScreen(
            initialLessonId: lessonId,
            initialLessonTitle: title,
            initialMinutes: duration,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/project/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ProjectDetailScreen(projectId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/resources',
        builder: (context, state) => const ResourcesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/projects',
        builder: (context, state) => const ProjectsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/notes',
        builder: (context, state) => const NotesScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/note-editor',
        builder: (context, state) {
          final noteId = state.uri.queryParameters['id'];
          final lessonId = state.uri.queryParameters['lessonId'];
          final lessonTitle = state.uri.queryParameters['lessonTitle'];
          return NoteEditorScreen(
            noteId: noteId,
            initialLessonId: lessonId,
            initialLessonTitle: lessonTitle,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/course/:id',
        builder: (context, state) {
          final courseId = state.pathParameters['id'] ?? '';
          return CourseDetailScreen(monthId: courseId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/practice',
        builder: (context, state) => const PracticeScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/search',
        builder: (context, state) => const GlobalSearchScreen(),
      ),
    ],
  );
});
