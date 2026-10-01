import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/app_providers.dart';
import '../../common/widgets/custom_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding Form State
  final TextEditingController _nameController =
      TextEditingController(text: 'Developer');
  int _selectedDailyMinutes = 60;
  TimeOfDay _preferredTime = const TimeOfDay(hour: 19, minute: 0);
  final Set<int> _selectedDays = {1, 2, 3, 4, 5}; // Mon to Fri

  final List<int> _minuteOptions = [30, 60, 120, 180, 240];
  final Map<int, String> _minuteLabels = {
    30: '30 min',
    60: '1 hour',
    120: '2 hours',
    180: '3 hours',
    240: '4+ hours',
  };

  final Map<int, String> _dayLabels = {
    1: 'Mon',
    2: 'Tue',
    3: 'Wed',
    4: 'Thu',
    5: 'Fri',
    6: 'Sat',
    7: 'Sun',
  };

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    final name = _nameController.text.trim().isEmpty
        ? 'Developer'
        : _nameController.text.trim();

    await ref.read(userProfileProvider.notifier).completeOnboarding(
          name: name,
          dailyGoalMinutes: _selectedDailyMinutes,
          preferredStudyTimeHour: _preferredTime.hour,
          preferredStudyTimeMinute: _preferredTime.minute,
          studyDays: _selectedDays.toList()..sort(),
        );

    // Schedule notification
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.requestPermissions();
    await notificationService.scheduleDailyReminder(
      hour: _preferredTime.hour,
      minute: _preferredTime.minute,
      studyDays: _selectedDays.toList()..sort(),
    );

    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space20,
                vertical: AppDimensions.space12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // DevPath Logo Tag
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space8),
                      const Text(
                        'DevPath',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < 3)
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          3,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Skip'),
                    ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _buildScreen1(),
                  _buildScreen2(),
                  _buildScreen3(),
                  _buildScreen4(),
                ],
              ),
            ),

            // Bottom Navigation & Progress Dots
            Padding(
              padding: const EdgeInsets.all(AppDimensions.space24),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.darkBorder,
                          borderRadius: AppDimensions.radiusPill,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppDimensions.space20),
                  CustomButton(
                    text: _currentPage == 3
                        ? 'Start My Dev Journey'
                        : 'Continue',
                    icon: _currentPage == 3
                        ? Icons.rocket_launch_rounded
                        : Icons.arrow_forward_rounded,
                    isFullWidth: true,
                    onPressed: _nextPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreen1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(90),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/images/app_icon.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space32),
          const Text(
            'Your 6-Month Journey\nStarts Here',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryDark,
              height: 1.2,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          const Text(
            'Go from zero programming knowledge to being job-ready for an IT and software development role with a curated, battle-tested learning path.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondaryDark,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen2() {
    final stages = [
      {'title': 'Learn', 'desc': 'Core concepts & syntax', 'icon': Icons.menu_book_rounded},
      {'title': 'Practice', 'desc': 'Exercises & algorithms', 'icon': Icons.code_rounded},
      {'title': 'Build', 'desc': '6 full portfolio projects', 'icon': Icons.build_circle_rounded},
      {'title': 'Track', 'desc': 'Streaks, timers & pace', 'icon': Icons.insights_rounded},
      {'title': 'Get Job Ready', 'desc': 'Interviews & resume', 'icon': Icons.work_rounded},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Learn. Build. Track.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryDark,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          const Text(
            'A structured 5-stage loop proven to accelerate mastery.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: AppDimensions.space24),
          ...stages.map((s) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.space8),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
                vertical: AppDimensions.space12,
              ),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: AppDimensions.radiusMd,
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.space8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGlow,
                      borderRadius: AppDimensions.radiusSm,
                    ),
                    child: Icon(
                      s['icon'] as IconData,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['title'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                      Text(
                        s['desc'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScreen3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkCard,
              border: Border.all(color: AppColors.accentAmber),
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              size: 48,
              color: AppColors.accentAmber,
            ),
          ),
          const SizedBox(height: AppDimensions.space32),
          const Text(
            'Never Miss Your Study Time',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryDark,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          const Text(
            'Consistency is the single determining factor in breaking into tech. Set your daily study time and receive gentle high-priority alarms to keep your streak alive.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondaryDark,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppDimensions.space12),
          const Text(
            'Let\'s Build Your Roadmap',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppDimensions.space4),
          const Text(
            'Customize your pace and daily routine.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryDark,
            ),
          ),
          const SizedBox(height: AppDimensions.space20),

          // Name Field
          const Text(
            'What should we call you?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: AppColors.textPrimaryDark),
            decoration: const InputDecoration(
              hintText: 'e.g. Alex, Maya',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: AppDimensions.space20),

          // Daily Study Target
          const Text(
            'Daily study target:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _minuteOptions.map((minutes) {
              final isSelected = _selectedDailyMinutes == minutes;
              return ChoiceChip(
                label: Text(_minuteLabels[minutes]!),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedDailyMinutes = minutes);
                  }
                },
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.darkCard,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.darkBorder,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimensions.space20),

          // Preferred Study Time
          const Text(
            'Preferred study time:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          InkWell(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _preferredTime,
              );
              if (picked != null) {
                setState(() => _preferredTime = picked);
              }
            },
            borderRadius: AppDimensions.radiusMd,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
                vertical: AppDimensions.space14,
              ),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: AppDimensions.radiusMd,
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      color: AppColors.primaryLight, size: 20),
                  const SizedBox(width: AppDimensions.space12),
                  Text(
                    _preferredTime.format(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Change',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.space20),

          // Days
          const Text(
            'Study days:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const SizedBox(height: AppDimensions.space8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _dayLabels.entries.map((entry) {
              final isSelected = _selectedDays.contains(entry.key);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      if (_selectedDays.length > 1) {
                        _selectedDays.remove(entry.key);
                      }
                    } else {
                      _selectedDays.add(entry.key);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.darkCard,
                    borderRadius: AppDimensions.radiusSm,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.darkBorder,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.black
                          : AppColors.textSecondaryDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimensions.space24),
        ],
      ),
    );
  }
}
