enum ResourceType {
  youtube,
  documentation,
  article,
  practice,
  project;

  String get label {
    switch (this) {
      case ResourceType.youtube:
        return 'YouTube';
      case ResourceType.documentation:
        return 'Documentation';
      case ResourceType.article:
        return 'Article';
      case ResourceType.practice:
        return 'Practice';
      case ResourceType.project:
        return 'Project';
    }
  }

  static ResourceType fromString(String? val) {
    if (val == null) return ResourceType.documentation;
    return ResourceType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => ResourceType.documentation,
    );
  }
}

class Resource {
  final String id;
  final String lessonId;
  final String title;
  final ResourceType type;
  final String url;
  final String duration;
  final String provider;
  final bool opened;

  const Resource({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.type,
    required this.url,
    required this.duration,
    required this.provider,
    this.opened = false,
  });

  Resource copyWith({
    String? id,
    String? lessonId,
    String? title,
    ResourceType? type,
    String? url,
    String? duration,
    String? provider,
    bool? opened,
  }) {
    return Resource(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      title: title ?? this.title,
      type: type ?? this.type,
      url: url ?? this.url,
      duration: duration ?? this.duration,
      provider: provider ?? this.provider,
      opened: opened ?? this.opened,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'title': title,
      'type': type.name,
      'url': url,
      'duration': duration,
      'provider': provider,
      'opened': opened,
    };
  }

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String? ?? '',
      title: json['title'] as String,
      type: ResourceType.fromString(json['type'] as String?),
      url: json['url'] as String,
      duration: json['duration'] as String? ?? '15 min',
      provider: json['provider'] as String? ?? 'Web',
      opened: json['opened'] as bool? ?? false,
    );
  }
}

class Lesson {
  final String id;
  final String topicId;
  final String monthId;
  final String title;
  final String description;
  final int estimatedMinutes;
  final bool completed;
  final DateTime? completedAt;
  final List<Resource> resources;

  const Lesson({
    required this.id,
    required this.topicId,
    required this.monthId,
    required this.title,
    required this.description,
    this.estimatedMinutes = 30,
    this.completed = false,
    this.completedAt,
    this.resources = const [],
  });

  Lesson copyWith({
    String? id,
    String? topicId,
    String? monthId,
    String? title,
    String? description,
    int? estimatedMinutes,
    bool? completed,
    DateTime? completedAt,
    List<Resource>? resources,
  }) {
    return Lesson(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      monthId: monthId ?? this.monthId,
      title: title ?? this.title,
      description: description ?? this.description,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      resources: resources ?? this.resources,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topicId': topicId,
      'monthId': monthId,
      'title': title,
      'description': description,
      'estimatedMinutes': estimatedMinutes,
      'completed': completed,
      'completedAt': completedAt?.toIso8601String(),
      'resources': resources.map((r) => r.toJson()).toList(),
    };
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      topicId: json['topicId'] as String? ?? '',
      monthId: json['monthId'] as String? ?? '',
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 30,
      completed: json['completed'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      resources: (json['resources'] as List<dynamic>?)
              ?.map((r) => Resource.fromJson(r as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class Topic {
  final String id;
  final String monthId;
  final String title;
  final String description;
  final int order;
  final List<Lesson> lessons;

  const Topic({
    required this.id,
    required this.monthId,
    required this.title,
    required this.description,
    required this.order,
    this.lessons = const [],
  });

  Topic copyWith({
    String? id,
    String? monthId,
    String? title,
    String? description,
    int? order,
    List<Lesson>? lessons,
  }) {
    return Topic(
      id: id ?? this.id,
      monthId: monthId ?? this.monthId,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      lessons: lessons ?? this.lessons,
    );
  }

  int get totalMinutes =>
      lessons.fold(0, (sum, l) => sum + l.estimatedMinutes);

  int get completedLessonsCount =>
      lessons.where((l) => l.completed).length;

  double get progressPercentage =>
      lessons.isEmpty ? 0.0 : ((completedLessonsCount / lessons.length) * 100).clamp(0.0, 100.0);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monthId': monthId,
      'title': title,
      'description': description,
      'order': order,
      'lessons': lessons.map((l) => l.toJson()).toList(),
    };
  }

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      monthId: json['monthId'] as String? ?? '',
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((l) => Lesson.fromJson(l as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class Month {
  final String id;
  final int monthNumber;
  final String title;
  final String subtitle;
  final String description;
  final int order;
  final List<Topic> topics;

  const Month({
    required this.id,
    required this.monthNumber,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.order,
    this.topics = const [],
  });

  Month copyWith({
    String? id,
    int? monthNumber,
    String? title,
    String? subtitle,
    String? description,
    int? order,
    List<Topic>? topics,
  }) {
    return Month(
      id: id ?? this.id,
      monthNumber: monthNumber ?? this.monthNumber,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      description: description ?? this.description,
      order: order ?? this.order,
      topics: topics ?? this.topics,
    );
  }

  List<Lesson> get allLessons =>
      topics.expand((t) => t.lessons).toList();

  int get completedLessonsCount =>
      allLessons.where((l) => l.completed).length;

  int get totalLessonsCount => allLessons.length;

  double get progressPercentage =>
      totalLessonsCount == 0 ? 0.0 : ((completedLessonsCount / totalLessonsCount) * 100).clamp(0.0, 100.0);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monthNumber': monthNumber,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'order': order,
      'topics': topics.map((t) => t.toJson()).toList(),
    };
  }

  factory Month.fromJson(Map<String, dynamic> json) {
    return Month(
      id: json['id'] as String,
      monthNumber: (json['monthNumber'] as num?)?.toInt() ?? 1,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      description: json['description'] as String? ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      topics: (json['topics'] as List<dynamic>?)
              ?.map((t) => Topic.fromJson(t as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
