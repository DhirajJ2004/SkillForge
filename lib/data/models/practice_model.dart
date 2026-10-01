class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String? codeSnippet;
  final String questionType; // 'mcq', 'code_analysis', 'debugging'

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.codeSnippet,
    this.questionType = 'mcq',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
      'codeSnippet': codeSnippet,
      'questionType': questionType,
    };
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      correctIndex: (json['correctIndex'] as num?)?.toInt() ?? 0,
      explanation: json['explanation'] as String? ?? '',
      codeSnippet: json['codeSnippet'] as String?,
      questionType: json['questionType'] as String? ?? 'mcq',
    );
  }
}

class PracticeAttempt {
  final String id;
  final String moduleId;
  final String moduleTitle;
  final String category;
  final String difficulty;
  final int score;
  final int totalQuestions;
  final double accuracy;
  final DateTime completedAt;
  final int durationSeconds;

  const PracticeAttempt({
    required this.id,
    required this.moduleId,
    required this.moduleTitle,
    required this.category,
    required this.difficulty,
    required this.score,
    required this.totalQuestions,
    required this.accuracy,
    required this.completedAt,
    this.durationSeconds = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleId': moduleId,
      'moduleTitle': moduleTitle,
      'category': category,
      'difficulty': difficulty,
      'score': score,
      'totalQuestions': totalQuestions,
      'accuracy': accuracy,
      'completedAt': completedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
    };
  }

  factory PracticeAttempt.fromJson(Map<String, dynamic> json) {
    return PracticeAttempt(
      id: json['id'] as String? ?? '',
      moduleId: json['moduleId'] as String? ?? '',
      moduleTitle: json['moduleTitle'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      difficulty: json['difficulty'] as String? ?? 'Beginner',
      score: (json['score'] as num?)?.toInt() ?? 0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
    );
  }
}

class PracticeStatsSummary {
  final int totalExercisesCompleted;
  final int totalQuestionsAttempted;
  final int totalCorrectAnswers;
  final double overallAccuracy;
  final String weakTopic;
  final String strongTopic;
  final List<PracticeAttempt> recentAttempts;

  const PracticeStatsSummary({
    required this.totalExercisesCompleted,
    required this.totalQuestionsAttempted,
    required this.totalCorrectAnswers,
    required this.overallAccuracy,
    required this.weakTopic,
    required this.strongTopic,
    this.recentAttempts = const [],
  });

  factory PracticeStatsSummary.fromAttempts(List<PracticeAttempt> attempts) {
    if (attempts.isEmpty) {
      return const PracticeStatsSummary(
        totalExercisesCompleted: 0,
        totalQuestionsAttempted: 0,
        totalCorrectAnswers: 0,
        overallAccuracy: 0.0,
        weakTopic: 'None yet',
        strongTopic: 'None yet',
        recentAttempts: [],
      );
    }

    int totalQuestions = 0;
    int totalCorrect = 0;
    final Map<String, List<double>> categoryAccuracies = {};

    for (final a in attempts) {
      totalQuestions += a.totalQuestions;
      totalCorrect += a.score;
      categoryAccuracies.putIfAbsent(a.category, () => []).add(a.accuracy);
    }

    final double avgAccuracy = totalQuestions > 0
        ? ((totalCorrect / totalQuestions) * 100).clamp(0.0, 100.0)
        : 0.0;

    String weakest = 'None yet';
    double minAcc = 101.0;
    String strongest = 'None yet';
    double maxAcc = -1.0;

    categoryAccuracies.forEach((cat, accList) {
      final avg = accList.reduce((a, b) => a + b) / accList.length;
      if (avg < minAcc) {
        minAcc = avg;
        weakest = cat;
      }
      if (avg > maxAcc) {
        maxAcc = avg;
        strongest = cat;
      }
    });

    return PracticeStatsSummary(
      totalExercisesCompleted: attempts.length,
      totalQuestionsAttempted: totalQuestions,
      totalCorrectAnswers: totalCorrect,
      overallAccuracy: avgAccuracy,
      weakTopic: weakest,
      strongTopic: strongest,
      recentAttempts: attempts,
    );
  }
}
