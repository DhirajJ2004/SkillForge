class UserProfile {
  final String id;
  final String name;
  final int dailyGoalMinutes;
  final int preferredStudyTimeHour;
  final int preferredStudyTimeMinute;
  final List<int> studyDays; // 1 = Mon, 7 = Sun
  final DateTime createdAt;
  final bool isOnboarded;

  const UserProfile({
    required this.id,
    required this.name,
    this.dailyGoalMinutes = 60,
    this.preferredStudyTimeHour = 19, // 7:00 PM
    this.preferredStudyTimeMinute = 0,
    this.studyDays = const [1, 2, 3, 4, 5], // Mon to Fri
    required this.createdAt,
    this.isOnboarded = false,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    int? dailyGoalMinutes,
    int? preferredStudyTimeHour,
    int? preferredStudyTimeMinute,
    List<int>? studyDays,
    DateTime? createdAt,
    bool? isOnboarded,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      preferredStudyTimeHour:
          preferredStudyTimeHour ?? this.preferredStudyTimeHour,
      preferredStudyTimeMinute:
          preferredStudyTimeMinute ?? this.preferredStudyTimeMinute,
      studyDays: studyDays ?? this.studyDays,
      createdAt: createdAt ?? this.createdAt,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dailyGoalMinutes': dailyGoalMinutes,
      'preferredStudyTimeHour': preferredStudyTimeHour,
      'preferredStudyTimeMinute': preferredStudyTimeMinute,
      'studyDays': studyDays,
      'createdAt': createdAt.toIso8601String(),
      'isOnboarded': isOnboarded,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? 'user_default',
      name: json['name'] as String? ?? 'Developer',
      dailyGoalMinutes: (json['dailyGoalMinutes'] as num?)?.toInt() ?? 60,
      preferredStudyTimeHour:
          (json['preferredStudyTimeHour'] as num?)?.toInt() ?? 19,
      preferredStudyTimeMinute:
          (json['preferredStudyTimeMinute'] as num?)?.toInt() ?? 0,
      studyDays: (json['studyDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [1, 2, 3, 4, 5],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isOnboarded: json['isOnboarded'] as bool? ?? false,
    );
  }

  static UserProfile defaultProfile() {
    return UserProfile(
      id: 'default_dev',
      name: 'Developer',
      dailyGoalMinutes: 60,
      preferredStudyTimeHour: 19,
      preferredStudyTimeMinute: 0,
      studyDays: const [1, 2, 3, 4, 5],
      createdAt: DateTime.now(),
      isOnboarded: false,
    );
  }
}
