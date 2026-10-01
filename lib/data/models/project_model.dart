class ProjectTask {
  final String id;
  final String title;
  final bool completed;

  const ProjectTask({
    required this.id,
    required this.title,
    this.completed = false,
  });

  ProjectTask copyWith({
    String? id,
    String? title,
    bool? completed,
  }) {
    return ProjectTask(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
    };
  }

  factory ProjectTask.fromJson(Map<String, dynamic> json) {
    return ProjectTask(
      id: json['id'] as String,
      title: json['title'] as String,
      completed: json['completed'] as bool? ?? false,
    );
  }
}

class Project {
  final String id;
  final int monthNumber;
  final String title;
  final String description;
  final List<String> technologies;
  final List<ProjectTask> tasks;
  final String githubUrl;
  final String liveUrl;
  final String notes;

  const Project({
    required this.id,
    required this.monthNumber,
    required this.title,
    required this.description,
    required this.technologies,
    required this.tasks,
    this.githubUrl = '',
    this.liveUrl = '',
    this.notes = '',
  });

  int get completedTasksCount => tasks.where((t) => t.completed).length;

  double get progressPercentage =>
      tasks.isEmpty ? 0.0 : ((completedTasksCount / tasks.length) * 100).clamp(0.0, 100.0);

  bool get isCompleted =>
      tasks.isNotEmpty && completedTasksCount == tasks.length;

  Project copyWith({
    String? id,
    int? monthNumber,
    String? title,
    String? description,
    List<String>? technologies,
    List<ProjectTask>? tasks,
    String? githubUrl,
    String? liveUrl,
    String? notes,
  }) {
    return Project(
      id: id ?? this.id,
      monthNumber: monthNumber ?? this.monthNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      technologies: technologies ?? this.technologies,
      tasks: tasks ?? this.tasks,
      githubUrl: githubUrl ?? this.githubUrl,
      liveUrl: liveUrl ?? this.liveUrl,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'monthNumber': monthNumber,
      'title': title,
      'description': description,
      'technologies': technologies,
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'githubUrl': githubUrl,
      'liveUrl': liveUrl,
      'notes': notes,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      monthNumber: (json['monthNumber'] as num?)?.toInt() ?? 1,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      technologies: (json['technologies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((t) => ProjectTask.fromJson(t as Map<String, dynamic>))
              .toList() ??
          const [],
      githubUrl: json['githubUrl'] as String? ?? '',
      liveUrl: json['liveUrl'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }
}
