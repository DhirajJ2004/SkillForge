class AppStats {
  final double overallProgress;
  final int completedLessons;
  final int totalLessons;
  final int currentStreak;
  final int longestStreak;
  final int totalStudyMinutes;
  final int weeklyStudyMinutes;
  final int monthlyStudyMinutes;
  final int studyDaysThisWeek;
  final int completedProjects;
  final int totalProjects;
  final double expectedProgress;

  const AppStats({
    this.overallProgress = 0.0,
    this.completedLessons = 0,
    this.totalLessons = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalStudyMinutes = 0,
    this.weeklyStudyMinutes = 0,
    this.monthlyStudyMinutes = 0,
    this.studyDaysThisWeek = 0,
    this.completedProjects = 0,
    this.totalProjects = 0,
    this.expectedProgress = 0.0,
  });

  int get remainingLessons => totalLessons - completedLessons;

  double get paceDifference => overallProgress - expectedProgress;

  bool get isAheadOfPace => paceDifference >= 0;

  String get paceMessage {
    if (totalLessons == 0 || overallProgress == 0 && expectedProgress < 1.0) {
      return 'Start your first lesson to build momentum!';
    }
    final diff = paceDifference.abs().round();
    if (diff <= 3) {
      return "You're right on track with your 6-month roadmap!";
    } else if (isAheadOfPace) {
      return "You're $diff% ahead of your planned pace. Outstanding!";
    } else {
      return "You're $diff% behind your planned pace. Let's get back on track.";
    }
  }
}
