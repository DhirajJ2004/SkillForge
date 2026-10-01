import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/roadmap_models.dart';
import '../../../providers/app_providers.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String monthId;

  const CourseDetailScreen({
    super.key,
    required this.monthId,
  });

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  final Set<String> _expandedTopicIds = {};

  @override
  void initState() {
    super.initState();
  }

  LinearGradient _getMonthGradient(int monthNum) {
    switch (monthNum) {
      case 1:
        return const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 2:
        return const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 3:
        return const LinearGradient(
          colors: [Color(0xFF6D28D9), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 4:
        return const LinearGradient(
          colors: [Color(0xFF701A75), Color(0xFF9333EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 5:
        return const LinearGradient(
          colors: [Color(0xFF047857), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 6:
        return const LinearGradient(
          colors: [Color(0xFFC2410C), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppColors.primaryGradient;
    }
  }

  List<String> _getCourseOutcomes(int monthNum) {
    switch (monthNum) {
      case 1:
        return [
          'Python syntax, variables, data structures & functions',
          'Object-oriented programming (classes, inheritance, polymorphism)',
          'Modular code, packages & clean coding practices',
          'File I/O, JSON serialization & error handling',
          'Git version control & GitHub workflows',
          'Relational database fundamentals with SQLite & SQL queries',
        ];
      case 2:
        return [
          'Modern semantic HTML5 and modern CSS3 layouts',
          'Responsive design with Flexbox, CSS Grid & mobile queries',
          'Modern JavaScript (ES6+, async/await, closures, promises)',
          'DOM manipulation & event-driven frontends',
          'React components, hooks (useState, useEffect, custom hooks)',
          'State management and consuming RESTful web APIs',
        ];
      case 3:
        return [
          'FastAPI framework architecture & dependency injection',
          'Pydantic request validation and response models',
          'Relational database modeling with PostgreSQL & SQLAlchemy',
          'JWT authentication, hashed passwords & role permissions',
          'RESTful API design and OpenAPI documentation',
          'Writing comprehensive integration tests with pytest',
        ];
      case 4:
        return [
          'Modern LLM architectures and API prompt engineering',
          'LangChain & LlamaIndex document loaders and chunking',
          'Vector embeddings and ChromaDB vector indexing',
          'Retrieval-Augmented Generation (RAG) query pipelines',
          'Autonomous Agent loops, tool calling & memory systems',
          'Evaluating hallucination & production AI deployment',
        ];
      case 5:
        return [
          'Linux CLI, bash scripting, permissions & process management',
          'Docker containerization, multi-stage builds & Docker Compose',
          'Continuous Integration & Continuous Deployment (CI/CD)',
          'Cloud infrastructure with AWS (EC2, S3, RDS, IAM)',
          'Nginx reverse proxy, SSL certificates & domain config',
          'Application logging, health metrics & uptime monitoring',
        ];
      case 6:
        return [
          'Big-O space and time complexity analysis',
          'Core data structures (Arrays, Linked Lists, Stacks, Queues)',
          'Advanced data structures (Hash Tables, Trees, Graphs, Heaps)',
          'Algorithmic patterns (Two Pointers, Sliding Window, DFS/BFS)',
          'System design fundamentals & scaling architectures',
          'Technical behavioral & coding interview simulation',
        ];
      default:
        return [
          'Comprehensive foundations and hands-on code exercises',
          'Real-world portfolio projects tested in production',
          'Best practices, code hygiene & interview readiness',
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final curriculum = ref.watch(curriculumProvider);
    final month = curriculum.cast<Month?>().firstWhere(
          (m) => m?.id == widget.monthId,
          orElse: () => null,
        );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    if (month == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(title: const Text('Course Not Found')),
        body: const Center(
          child: Text('This course does not exist in the curriculum.'),
        ),
      );
    }

    // Default first topic expanded
    if (_expandedTopicIds.isEmpty && month.topics.isNotEmpty) {
      _expandedTopicIds.add(month.topics.first.id);
    }

    final firstIncompleteLesson = month.allLessons.cast<Lesson?>().firstWhere(
          (l) => !l!.completed,
          orElse: () =>
              month.allLessons.isNotEmpty ? month.allLessons.first : null,
        );

    final isCompleted = month.progressPercentage >= 100.0;
    final isStarted = month.progressPercentage > 0;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // Collapsible Hero Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(100),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: _getMonthGradient(month.monthNumber),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space10,
                        vertical: AppDimensions.space4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(60),
                        borderRadius: AppDimensions.radiusPill,
                      ),
                      child: Text(
                        'COURSE • MONTH ${month.monthNumber}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      month.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      month.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withAlpha(220),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Course Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Stats Row
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: AppDimensions.radiusMd,
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetaItem(
                          icon: Icons.video_library_outlined,
                          value: '${month.totalLessonsCount}',
                          label: 'Lessons',
                          isDark: isDark,
                        ),
                        _buildMetaDivider(isDark),
                        _buildMetaItem(
                          icon: Icons.schedule_rounded,
                          value: '${month.totalLessonsCount * 45 ~/ 60}h',
                          label: 'Content',
                          isDark: isDark,
                        ),
                        _buildMetaDivider(isDark),
                        _buildMetaItem(
                          icon: Icons.verified_outlined,
                          value: 'Certificate',
                          label: 'Upon Finish',
                          isDark: isDark,
                        ),
                        _buildMetaDivider(isDark),
                        _buildMetaItem(
                          icon: Icons.offline_bolt_outlined,
                          value: 'Offline',
                          label: 'Ready',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space20),

                  // Course Primary CTA
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (firstIncompleteLesson != null) {
                          context.push('/lesson/${firstIncompleteLesson.id}');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDimensions.radiusMd,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isStarted
                                ? Icons.play_circle_fill_rounded
                                : Icons.rocket_launch_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCompleted
                                ? 'Review Course'
                                : isStarted
                                    ? 'Continue Course (${month.progressPercentage.toInt()}%)'
                                    : 'Start Course Now',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space24),

                  // What You'll Learn Section
                  Text(
                    "What You'll Learn",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space12),
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: AppDimensions.radiusMd,
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: _getCourseOutcomes(month.monthNumber).map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.35,
                                    color: textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space24),

                  // Course Curriculum Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Course Curriculum',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        '${month.completedLessonsCount}/${month.totalLessonsCount} completed',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space12),

                  // Expandable Topics & Lessons
                  ...month.topics.map((topic) {
                    final isExpanded = _expandedTopicIds.contains(topic.id);
                    final topicCompleted = topic.completedLessonsCount ==
                            topic.lessons.length &&
                        topic.lessons.isNotEmpty;

                    return Container(
                      margin:
                          const EdgeInsets.only(bottom: AppDimensions.space12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: AppDimensions.radiusMd,
                        border: Border.all(
                          color: topicCompleted
                              ? AppColors.success.withAlpha(80)
                              : borderColor,
                        ),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedTopicIds.remove(topic.id);
                                } else {
                                  _expandedTopicIds.add(topic.id);
                                }
                              });
                            },
                            borderRadius: AppDimensions.radiusMd,
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(AppDimensions.space16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: topicCompleted
                                          ? AppColors.success.withAlpha(25)
                                          : AppColors.primary.withAlpha(20),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      topicCompleted
                                          ? Icons.check_rounded
                                          : Icons.folder_open_rounded,
                                      size: 16,
                                      color: topicCompleted
                                          ? AppColors.success
                                          : AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          topic.title,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: textPrimary,
                                          ),
                                        ),
                                        Text(
                                          '${topic.completedLessonsCount}/${topic.lessons.length} lessons • ${topic.progressPercentage.toInt()}%',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.expand_less_rounded
                                        : Icons.expand_more_rounded,
                                    color: textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isExpanded) ...[
                            const Divider(height: 1),
                            ...topic.lessons.asMap().entries.map((entry) {
                              final idx = entry.key + 1;
                              final lesson = entry.value;
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.space16,
                                  vertical: 2,
                                ),
                                leading: Icon(
                                  lesson.completed
                                      ? Icons.check_circle_rounded
                                      : Icons.play_circle_outline_rounded,
                                  size: 20,
                                  color: lesson.completed
                                      ? AppColors.success
                                      : AppColors.primary,
                                ),
                                title: Text(
                                  '$idx. ${lesson.title}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: lesson.completed
                                        ? FontWeight.w500
                                        : FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  '${lesson.resources.length} resources • ~45 min',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: AppColors.textTertiaryDark,
                                ),
                                onTap: () =>
                                    context.push('/lesson/${lesson.id}'),
                              );
                            }),
                          ],
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: AppDimensions.space32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem({
    required IconData icon,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildMetaDivider(bool isDark) {
    return Container(
      width: 1,
      height: 30,
      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }
}
