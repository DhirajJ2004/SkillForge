class StudySession {
  final String id;
  final String lessonId;
  final String lessonTitle;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final bool completed;

  const StudySession({
    required this.id,
    required this.lessonId,
    required this.lessonTitle,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.completed = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'completed': completed,
    };
  }

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String? ?? '',
      lessonTitle: json['lessonTitle'] as String? ?? 'Study Focus',
      startTime: DateTime.tryParse(json['startTime'] as String? ?? '') ??
          DateTime.now(),
      endTime:
          DateTime.tryParse(json['endTime'] as String? ?? '') ?? DateTime.now(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      completed: json['completed'] as bool? ?? true,
    );
  }
}
