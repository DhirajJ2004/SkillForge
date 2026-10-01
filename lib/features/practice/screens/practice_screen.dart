import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/practice_model.dart';
import '../../../providers/app_providers.dart';
import '../../common/widgets/section_header.dart';

class PracticeQuizItem {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const PracticeQuizItem({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class PracticeModule {
  final String id;
  final String title;
  final String category;
  final String difficulty;
  final int questionCount;
  final int estimatedMinutes;
  final IconData icon;
  final Color accentColor;
  final List<PracticeQuizItem> questions;

  const PracticeModule({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.questionCount,
    required this.estimatedMinutes,
    required this.icon,
    required this.accentColor,
    required this.questions,
  });
}

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = const [
    'All',
    'Python',
    'SQL',
    'JavaScript',
    'React',
    'FastAPI',
    'DSA',
    'AI',
  ];

  late final List<PracticeModule> _modules;

  @override
  void initState() {
    super.initState();
    _modules = [
      const PracticeModule(
        id: 'py_fund',
        title: 'Python Syntax & Data Structures',
        category: 'Python',
        difficulty: 'Beginner',
        questionCount: 5,
        estimatedMinutes: 10,
        icon: Icons.code_rounded,
        accentColor: AppColors.primary,
        questions: [
          PracticeQuizItem(
            question: 'What is the output of `print([1, 2, 3][::-1])` in Python?',
            options: ['[1, 2, 3]', '[3, 2, 1]', '[3, 2]', 'IndexError'],
            correctIndex: 1,
            explanation: 'The slice step of -1 reverses the sequence.',
          ),
          PracticeQuizItem(
            question: 'Which built-in Python collection does NOT allow duplicate elements?',
            options: ['List', 'Tuple', 'Set', 'Dictionary keys'],
            correctIndex: 2,
            explanation: 'Sets are unordered collections of unique elements.',
          ),
          PracticeQuizItem(
            question: 'What is the time complexity of looking up a key in a Python dict on average?',
            options: ['O(n)', 'O(log n)', 'O(1)', 'O(n log n)'],
            correctIndex: 2,
            explanation: 'Python dicts use hash tables, providing O(1) average lookup.',
          ),
          PracticeQuizItem(
            question: 'What keyword defines a generator function in Python?',
            options: ['return', 'yield', 'async', 'lambda'],
            correctIndex: 1,
            explanation: 'yield produces values on the fly while preserving function state.',
          ),
          PracticeQuizItem(
            question: 'What method is called when an object is instantiated in Python?',
            options: ['__new__', '__init__', '__start__', '__create__'],
            correctIndex: 1,
            explanation: '__init__ is the initializer method for instances in Python.',
          ),
        ],
      ),
      const PracticeModule(
        id: 'sql_queries',
        title: 'SQL Joins & Group By',
        category: 'SQL',
        difficulty: 'Intermediate',
        questionCount: 4,
        estimatedMinutes: 8,
        icon: Icons.storage_rounded,
        accentColor: AppColors.accentCyan,
        questions: [
          PracticeQuizItem(
            question: 'Which JOIN returns all rows from the left table and matched rows from the right table?',
            options: ['INNER JOIN', 'LEFT JOIN', 'FULL JOIN', 'CROSS JOIN'],
            correctIndex: 1,
            explanation: 'LEFT JOIN preserves all rows from the left table, filling NULLs for unmatched right rows.',
          ),
          PracticeQuizItem(
            question: 'Which clause filters groups created by GROUP BY?',
            options: ['WHERE', 'HAVING', 'ORDER BY', 'LIMIT'],
            correctIndex: 1,
            explanation: 'HAVING filters aggregate groups; WHERE filters rows before grouping.',
          ),
          PracticeQuizItem(
            question: 'What index structure is most commonly used by default in relational SQL engines?',
            options: ['B-Tree', 'Hash Table', 'Trie', 'Linked List'],
            correctIndex: 0,
            explanation: 'B-Trees support efficient range scans and point queries.',
          ),
          PracticeQuizItem(
            question: 'What does ACID stand for in databases?',
            options: [
              'Atomicity, Consistency, Isolation, Durability',
              'Accuracy, Concurrency, Integrity, Data',
              'Access, Control, Indexing, Delivery',
              'Automated, Cached, Isolated, Durable',
            ],
            correctIndex: 0,
            explanation: 'ACID guarantees reliable transaction processing.',
          ),
        ],
      ),
      const PracticeModule(
        id: 'js_async',
        title: 'JavaScript Async & Event Loop',
        category: 'JavaScript',
        difficulty: 'Intermediate',
        questionCount: 4,
        estimatedMinutes: 10,
        icon: Icons.javascript_rounded,
        accentColor: AppColors.accentAmber,
        questions: [
          PracticeQuizItem(
            question: 'In what queue do Promise callbacks (then/catch) execute in Node/V8?',
            options: ['Macrotask queue', 'Microtask queue', 'Render queue', 'Call stack directly'],
            correctIndex: 1,
            explanation: 'Promises execute in the microtask queue, which has higher priority than macrotasks like setTimeout.',
          ),
          PracticeQuizItem(
            question: 'What is the output of `typeof null` in JavaScript?',
            options: ['"null"', '"undefined"', '"object"', '"boolean"'],
            correctIndex: 2,
            explanation: 'typeof null returning "object" is a historic JS bug preserved for backwards compatibility.',
          ),
          PracticeQuizItem(
            question: 'What keyword pauses execution of an async function until a Promise resolves?',
            options: ['pause', 'wait', 'await', 'defer'],
            correctIndex: 2,
            explanation: 'await pauses execution inside async functions until promise fulfillment.',
          ),
          PracticeQuizItem(
            question: 'Which array method returns a brand new array with transformed elements?',
            options: ['forEach', 'map', 'filter', 'reduce'],
            correctIndex: 1,
            explanation: 'Array.prototype.map transforms each element into a new array.',
          ),
        ],
      ),
      const PracticeModule(
        id: 'fastapi_apis',
        title: 'FastAPI Validation & Dependency Injection',
        category: 'FastAPI',
        difficulty: 'Intermediate',
        questionCount: 3,
        estimatedMinutes: 7,
        icon: Icons.dns_rounded,
        accentColor: AppColors.accentEmerald,
        questions: [
          PracticeQuizItem(
            question: 'What library powers schema validation and serialization in FastAPI?',
            options: ['Marshmallow', 'Pydantic', 'Cerberus', 'Attrs'],
            correctIndex: 1,
            explanation: 'FastAPI is built natively on Pydantic models for data validation.',
          ),
          PracticeQuizItem(
            question: 'Which parameter helper declares that a parameter comes from the HTTP request headers?',
            options: ['Query', 'Path', 'Header', 'Body'],
            correctIndex: 2,
            explanation: 'Header() extracts values from HTTP headers.',
          ),
          PracticeQuizItem(
            question: 'What function is passed into `Depends()` to share DB sessions across endpoints?',
            options: ['get_db', 'yield_session', 'use_connection', 'connect_db'],
            correctIndex: 0,
            explanation: 'A generator dependency function (like get_db) yields the session and closes it on completion.',
          ),
        ],
      ),
      const PracticeModule(
        id: 'dsa_patterns',
        title: 'Two Pointers & Sliding Window',
        category: 'DSA',
        difficulty: 'Advanced',
        questionCount: 3,
        estimatedMinutes: 12,
        icon: Icons.polyline_rounded,
        accentColor: AppColors.accentOrange,
        questions: [
          PracticeQuizItem(
            question: 'What is the ideal time complexity for Two Sum on a SORTED array?',
            options: ['O(n^2)', 'O(n log n)', 'O(n)', 'O(1)'],
            correctIndex: 2,
            explanation: 'With a sorted array, two pointers from left and right find the target in O(n) time and O(1) space.',
          ),
          PracticeQuizItem(
            question: 'Which pattern is ideal for finding the longest substring with at most K distinct characters?',
            options: ['Binary Search', 'Sliding Window', 'Dynamic Programming', 'Monotonic Stack'],
            correctIndex: 1,
            explanation: 'Sliding window expands and shrinks a boundary to maintain constraints in O(n) time.',
          ),
          PracticeQuizItem(
            question: 'What is the time complexity of pushing an element to a Min-Heap of size N?',
            options: ['O(1)', 'O(log N)', 'O(N)', 'O(N log N)'],
            correctIndex: 1,
            explanation: 'Inserting into a binary heap requires percolating up, taking O(log N) operations.',
          ),
        ],
      ),
    ];
  }

  void _startPracticeSession(PracticeModule module) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PracticeQuizSheet(
        module: module,
        onFinish: (score, total) async {
          final attempt = PracticeAttempt(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            moduleId: module.id,
            moduleTitle: module.title,
            category: module.category,
            difficulty: module.difficulty,
            score: score,
            totalQuestions: total,
            accuracy: total > 0 ? (score / total) * 100 : 0.0,
            completedAt: DateTime.now(),
            durationSeconds: module.estimatedMinutes * 60,
          );
          await ref.read(practiceAttemptsProvider.notifier).recordAttempt(attempt);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(practiceStatsProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    final filtered = _selectedCategory == 'All'
        ? _modules
        : _modules.where((m) => m.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('SkillForge Practice Hub'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space20,
            vertical: AppDimensions.space12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Test Your Intuition',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Reinforce active concepts through technical questions.',
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Practice Stats Overview
              Container(
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppDimensions.radiusLg,
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Completed', '${stats.totalExercisesCompleted}',
                        AppColors.primary, textPrimary, textSecondary),
                    Container(width: 1, height: 32, color: borderColor),
                    _buildStatCol('Questions', '${stats.totalQuestionsAttempted}',
                        AppColors.secondary, textPrimary, textSecondary),
                    Container(width: 1, height: 32, color: borderColor),
                    _buildStatCol('Accuracy', '${stats.overallAccuracy.toStringAsFixed(0)}%',
                        AppColors.success, textPrimary, textSecondary),
                    Container(width: 1, height: 32, color: borderColor),
                    _buildStatCol('Weak Area', stats.weakTopic,
                        AppColors.accentOrange, textPrimary, textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space20),

              // Category Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = cat == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        backgroundColor: cardBg,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : textPrimary,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : borderColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDimensions.radiusPill,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppDimensions.space20),

              // Modules List
              SectionHeader(
                title: 'Available Exercises',
                subtitle: 'Practice drills tailored to your learning stage',
              ),
              const SizedBox(height: AppDimensions.space8),

              ...filtered.map((module) {
                return Container(
                  margin: const EdgeInsets.only(bottom: AppDimensions.space14),
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: AppDimensions.radiusMd,
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: module.accentColor.withAlpha(25),
                              borderRadius: AppDimensions.radiusSm,
                            ),
                            child: Icon(
                              module.icon,
                              color: module.accentColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  module.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${module.difficulty} • ${module.questionCount} Questions • ~${module.estimatedMinutes} min',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.space14),
                      SizedBox(
                        width: double.infinity,
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () => _startPracticeSession(module),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: module.accentColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppDimensions.radiusSm,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow_rounded, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Start Practice',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Recent Attempts Section
              if (stats.recentAttempts.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.space20),
                SectionHeader(
                  title: 'Recent Sessions',
                  subtitle: 'History of your latest practice attempts',
                ),
                const SizedBox(height: AppDimensions.space8),
                ...stats.recentAttempts.take(5).map((attempt) {
                  final isPassing = attempt.accuracy >= 70;
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppDimensions.space10),
                    padding: const EdgeInsets.all(AppDimensions.space12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: AppDimensions.radiusSm,
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                attempt.moduleTitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${attempt.category} • ${attempt.difficulty}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPassing
                                ? AppColors.success.withAlpha(20)
                                : AppColors.accentOrange.withAlpha(20),
                            borderRadius: AppDimensions.radiusPill,
                          ),
                          child: Text(
                            '${attempt.score}/${attempt.totalQuestions} (${attempt.accuracy.toStringAsFixed(0)}%)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isPassing
                                  ? AppColors.success
                                  : AppColors.accentOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: AppDimensions.space32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(
    String label,
    String value,
    Color valueColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PracticeQuizSheet extends StatefulWidget {
  final PracticeModule module;
  final Function(int score, int total) onFinish;

  const _PracticeQuizSheet({
    required this.module,
    required this.onFinish,
  });

  @override
  State<_PracticeQuizSheet> createState() => _PracticeQuizSheetState();
}

class _PracticeQuizSheetState extends State<_PracticeQuizSheet> {
  int _currentIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _score = 0;

  void _submitAnswer() {
    if (_selectedOption == null) return;
    final currentQ = widget.module.questions[_currentIndex];
    final isCorrect = _selectedOption == currentQ.correctIndex;
    if (isCorrect) {
      _score += 1;
    }
    setState(() {
      _answered = true;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.module.questions.length - 1) {
      setState(() {
        _currentIndex += 1;
        _selectedOption = null;
        _answered = false;
      });
    } else {
      widget.onFinish(_score, widget.module.questions.length);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Practice Complete! You scored $_score/${widget.module.questions.length}',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCard : Colors.white;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final q = widget.module.questions[_currentIndex];
    final isLast = _currentIndex == widget.module.questions.length - 1;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(AppDimensions.space20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.module.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Text(
                '${_currentIndex + 1} of ${widget.module.questions.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space16),

          // Question
          Text(
            q.question,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppDimensions.space16),

          // Options
          Expanded(
            child: ListView.builder(
              itemCount: q.options.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedOption == index;
                final isCorrect = index == q.correctIndex;

                Color optionBorder = borderColor;
                Color optionBg = Colors.transparent;

                if (_answered) {
                  if (isCorrect) {
                    optionBorder = AppColors.success;
                    optionBg = AppColors.success.withAlpha(20);
                  } else if (isSelected) {
                    optionBorder = AppColors.error;
                    optionBg = AppColors.error.withAlpha(20);
                  }
                } else if (isSelected) {
                  optionBorder = AppColors.primary;
                  optionBg = AppColors.primary.withAlpha(15);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: _answered
                        ? null
                        : () {
                            setState(() {
                              _selectedOption = index;
                            });
                          },
                    borderRadius: AppDimensions.radiusSm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: optionBg,
                        borderRadius: AppDimensions.radiusSm,
                        border: Border.all(color: optionBorder, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : textSecondary,
                              ),
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                            ),
                            child: Text(
                              String.fromCharCode(65 + index),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              q.options[index],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Explanation when answered
          if (_answered) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                borderRadius: AppDimensions.radiusSm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      q.explanation,
                      style: TextStyle(
                        fontSize: 12,
                        color: textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space12),
          ],

          // Action button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _selectedOption == null
                  ? null
                  : _answered
                      ? _nextQuestion
                      : _submitAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.radiusMd,
                ),
              ),
              child: Text(
                _answered
                    ? (isLast ? 'Finish Practice' : 'Next Question')
                    : 'Check Answer',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
