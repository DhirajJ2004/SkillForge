import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/study_session.dart';
import '../../../providers/app_providers.dart';
import '../../common/widgets/custom_button.dart';

class StudySessionScreen extends ConsumerStatefulWidget {
  final String? initialLessonId;
  final String? initialLessonTitle;
  final int initialMinutes;

  const StudySessionScreen({
    super.key,
    this.initialLessonId,
    this.initialLessonTitle,
    this.initialMinutes = 30,
  });

  @override
  ConsumerState<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends ConsumerState<StudySessionScreen>
    with WidgetsBindingObserver {
  late int _targetMinutes;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isFinishing = false;
  late DateTime _sessionStartTime;
  int _secondsElapsed = 0;
  final Uuid _uuid = const Uuid();

  final List<int> _presetMinutes = [25, 30, 45, 60, 90];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _targetMinutes = widget.initialMinutes > 0 ? widget.initialMinutes : 30;
    _remainingSeconds = _targetMinutes * 60;
    _sessionStartTime = DateTime.now();
    // Auto-start timer
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Background lifecycle handling
    if (state == AppLifecycleState.resumed && _isRunning && !_isFinishing) {
      final elapsedSinceStart =
          DateTime.now().difference(_sessionStartTime).inSeconds;
      final calculatedRemaining =
          (_targetMinutes * 60) - elapsedSinceStart;
      if (calculatedRemaining <= 0) {
        setState(() {
          _remainingSeconds = 0;
          _secondsElapsed = _targetMinutes * 60;
          _isRunning = false;
        });
        _finishSession(completed: true);
      } else {
        setState(() {
          _remainingSeconds = calculatedRemaining;
          _secondsElapsed = elapsedSinceStart;
        });
      }
    }
  }

  void _startTimer() {
    if (_isFinishing) return;
    _timer?.cancel();
    _isRunning = true;
    _sessionStartTime =
        DateTime.now().subtract(Duration(seconds: _secondsElapsed));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          _secondsElapsed++;
        });
      } else {
        _timer?.cancel();
        _isRunning = false;
        _finishSession(completed: true);
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resumeTimer() {
    _startTimer();
  }

  void _setPreset(int minutes) {
    if (_isFinishing) return;
    _pauseTimer();
    setState(() {
      _targetMinutes = minutes;
      _remainingSeconds = minutes * 60;
      _secondsElapsed = 0;
      _sessionStartTime = DateTime.now();
    });
  }

  void _showCustomDurationDialog() {
    int customMins = _targetMinutes;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.darkCard,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.radiusLg,
            side: BorderSide(color: AppColors.darkBorder),
          ),
          title: const Text(
            'Custom Session Duration',
            style: TextStyle(color: AppColors.textPrimaryDark),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$customMins minutes',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Slider(
                value: customMins.toDouble(),
                min: 5,
                max: 180,
                divisions: 35,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setDialogState(() => customMins = val.round());
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _setPreset(customMins);
              },
              child: const Text('Set Duration'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishSession({bool completed = true}) async {
    if (_isFinishing) return;
    _timer?.cancel();

    if (_secondsElapsed == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session cancelled (0 study time elapsed).')),
        );
        context.pop();
      }
      return;
    }

    _isFinishing = true;
    setState(() => _isRunning = false);

    final actualDurationMinutes = (_secondsElapsed / 60).ceil();
    final effectiveMinutes =
        actualDurationMinutes > 0 ? actualDurationMinutes : 1;

    final lessonTitle = widget.initialLessonTitle ?? 'Focused Study';
    final lessonId = widget.initialLessonId ?? '';

    // Record session
    final session = StudySession(
      id: _uuid.v4(),
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      startTime: _sessionStartTime,
      endTime: DateTime.now(),
      durationMinutes: effectiveMinutes,
      completed: completed,
    );

    await ref.read(studySessionsProvider.notifier).recordSession(session);

    // Show completion modal safely
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showCompletionDialog(effectiveMinutes, lessonTitle, lessonId);
        }
      });
    }
  }

  void _showCompletionDialog(
      int minutes, String lessonTitle, String lessonId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.darkCard,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.radiusLg,
            side: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGlow,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🔥', style: TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: AppDimensions.space20),
              const Text(
                'Great work! 🔥',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppDimensions.space8),
              Text(
                '$minutes minutes added to your learning streak for "$lessonTitle".',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryDark,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppDimensions.space24),
              if (lessonId.isNotEmpty) ...[
                CustomButton(
                  text: 'Mark Lesson as Completed',
                  icon: Icons.check_circle_rounded,
                  isFullWidth: true,
                  onPressed: () {
                    ref
                        .read(curriculumProvider.notifier)
                        .toggleLesson(lessonId, true);
                    Navigator.of(ctx).pop();
                    context.pop();
                  },
                ),
                const SizedBox(height: AppDimensions.space10),
              ],
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.pop();
                },
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final lessonTitle = widget.initialLessonTitle ?? 'Focus Session';
    final totalTargetSeconds = _targetMinutes * 60;
    final progress = totalTargetSeconds > 0
        ? (_secondsElapsed / totalTargetSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Focus Session'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            _timer?.cancel();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space24,
            vertical: AppDimensions.space16,
          ),
          child: Column(
            children: [
              // Lesson Tag
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: AppDimensions.radiusPill,
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.code_rounded,
                        color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        lessonTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Circular Timer Display
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: AppColors.darkCard,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(_remainingSeconds),
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimaryDark,
                          letterSpacing: -1.5,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isRunning ? 'FOCUS MODE' : 'PAUSED',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: _isRunning
                              ? AppColors.primary
                              : AppColors.accentAmber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              // Preset Selector Chips + Custom Duration
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ..._presetMinutes.map((mins) {
                      final isSelected = _targetMinutes == mins;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text('${mins}m'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) _setPreset(mins);
                          },
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.darkCard,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.darkBorder,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.black
                                : AppColors.textSecondaryDark,
                          ),
                        ),
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ActionChip(
                        avatar: const Icon(Icons.tune_rounded, size: 14, color: AppColors.primaryLight),
                        label: Text(
                          !_presetMinutes.contains(_targetMinutes)
                              ? 'Custom (${_targetMinutes}m)'
                              : 'Custom',
                        ),
                        backgroundColor: !_presetMinutes.contains(_targetMinutes)
                            ? AppColors.primaryGlow
                            : AppColors.darkCard,
                        side: BorderSide(
                          color: !_presetMinutes.contains(_targetMinutes)
                              ? AppColors.primary
                              : AppColors.darkBorder,
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: !_presetMinutes.contains(_targetMinutes)
                              ? AppColors.primary
                              : AppColors.textSecondaryDark,
                        ),
                        onPressed: _showCustomDurationDialog,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.space24),

              // Controls
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: _isRunning ? 'Pause' : 'Resume',
                      icon: _isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      variant: _isRunning
                          ? ButtonVariant.secondary
                          : ButtonVariant.primary,
                      onPressed: _isFinishing
                          ? null
                          : () {
                              if (_isRunning) {
                                _pauseTimer();
                              } else {
                                _resumeTimer();
                              }
                            },
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: CustomButton(
                      text: _isFinishing ? 'Saving...' : 'Finish Session',
                      icon: Icons.done_all_rounded,
                      variant: ButtonVariant.outline,
                      isLoading: _isFinishing,
                      onPressed: _isFinishing
                          ? null
                          : () => _finishSession(completed: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),
            ],
          ),
        ),
      ),
    );
  }
}
