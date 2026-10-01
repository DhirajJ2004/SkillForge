import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool unlocked;
  final double progress; // 0.0 to 1.0
  final int xpReward;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.unlocked,
    required this.progress,
    required this.xpReward,
    this.unlockedAt,
  });
}

class UserXP {
  final int totalXP;
  final int currentLevel;
  final int xpIntoCurrentLevel;
  final int xpRequiredForNextLevel;
  final double levelProgress;
  final String levelTitle;

  const UserXP({
    required this.totalXP,
    required this.currentLevel,
    required this.xpIntoCurrentLevel,
    required this.xpRequiredForNextLevel,
    required this.levelProgress,
    required this.levelTitle,
  });

  factory UserXP.calculate({
    required int completedLessons,
    required int completedProjects,
    required int completedTasks,
    required int currentStreak,
    required int totalStudyMinutes,
    required int quizQuestionsCorrect,
    required int completedCourses,
  }) {
    // Deterministic XP Formula:
    // 50 XP per lesson completed
    // 100 XP per project task completed
    // 300 XP per full project finished
    // 500 XP per completed curriculum course
    // 10 XP per quiz question answered correctly
    // 25 XP per day of current streak
    // 1 XP per 2 minutes of study time
    int total = (completedLessons * 50) +
        (completedTasks * 100) +
        (completedProjects * 300) +
        (completedCourses * 500) +
        (quizQuestionsCorrect * 10) +
        (currentStreak * 25) +
        (totalStudyMinutes ~/ 2);

    // Level calculation: Each level requires 500 XP
    const int xpPerLevel = 500;
    final int level = (total ~/ xpPerLevel) + 1;
    final int remainder = total % xpPerLevel;
    final double progress = remainder / xpPerLevel;

    String title;
    if (level < 3) {
      title = 'Novice Developer';
    } else if (level < 6) {
      title = 'Junior Apprentice';
    } else if (level < 10) {
      title = 'Core Engineer';
    } else if (level < 15) {
      title = 'Senior Builder';
    } else {
      title = 'Lead Architect';
    }

    return UserXP(
      totalXP: total,
      currentLevel: level,
      xpIntoCurrentLevel: remainder,
      xpRequiredForNextLevel: xpPerLevel,
      levelProgress: progress,
      levelTitle: title,
    );
  }
}

class AchievementEngine {
  static List<Achievement> evaluate({
    required int completedLessons,
    required int completedProjects,
    required int completedCourses,
    required int streakDays,
    required int totalStudyMinutes,
    required int totalQuizQuestionsAttempted,
    required double highestQuizAccuracy,
  }) {
    return [
      Achievement(
        id: 'first_step',
        title: 'First Step',
        description: 'Complete your first lesson',
        icon: Icons.flag_rounded,
        color: const Color(0xFF2563EB),
        unlocked: completedLessons >= 1,
        progress: (completedLessons / 1).clamp(0.0, 1.0),
        xpReward: 50,
      ),
      Achievement(
        id: 'ten_lessons',
        title: 'Dedicated Learner',
        description: 'Complete 10 curriculum lessons',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF06B6D4),
        unlocked: completedLessons >= 10,
        progress: (completedLessons / 10).clamp(0.0, 1.0),
        xpReward: 150,
      ),
      Achievement(
        id: 'streak_7',
        title: '7-Day Streak',
        description: 'Study 7 days consecutively',
        icon: Icons.local_fire_department_rounded,
        color: const Color(0xFFF97316),
        unlocked: streakDays >= 7,
        progress: (streakDays / 7).clamp(0.0, 1.0),
        xpReward: 200,
      ),
      Achievement(
        id: 'first_project',
        title: 'Builder',
        description: 'Ship your first portfolio project',
        icon: Icons.rocket_launch_rounded,
        color: const Color(0xFF10B981),
        unlocked: completedProjects >= 1,
        progress: (completedProjects / 1).clamp(0.0, 1.0),
        xpReward: 250,
      ),
      Achievement(
        id: 'first_course',
        title: 'Milestone Finisher',
        description: 'Finish all lessons in a full course',
        icon: Icons.school_rounded,
        color: const Color(0xFF8B5CF6),
        unlocked: completedCourses >= 1,
        progress: (completedCourses / 1).clamp(0.0, 1.0),
        xpReward: 500,
      ),
      Achievement(
        id: 'quiz_master',
        title: 'Quiz Ace',
        description: 'Score 90% or higher on any quiz drill',
        icon: Icons.stars_rounded,
        color: const Color(0xFFF59E0B),
        unlocked: highestQuizAccuracy >= 90.0,
        progress: (highestQuizAccuracy / 90.0).clamp(0.0, 1.0),
        xpReward: 200,
      ),
      Achievement(
        id: 'fifty_questions',
        title: 'Problem Solver',
        description: 'Attempt 50 practice questions',
        icon: Icons.psychology_rounded,
        color: const Color(0xFFEC4899),
        unlocked: totalQuizQuestionsAttempted >= 50,
        progress: (totalQuizQuestionsAttempted / 50).clamp(0.0, 1.0),
        xpReward: 300,
      ),
      Achievement(
        id: 'ten_hours',
        title: 'Deep Focus',
        description: 'Log 10 hours of focused study time',
        icon: Icons.hourglass_top_rounded,
        color: const Color(0xFF6366F1),
        unlocked: totalStudyMinutes >= 600,
        progress: (totalStudyMinutes / 600).clamp(0.0, 1.0),
        xpReward: 400,
      ),
    ];
  }
}
