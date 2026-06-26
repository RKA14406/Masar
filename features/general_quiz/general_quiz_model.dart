class GeneralQuizQuestion {
  final String section;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String feedback;

  const GeneralQuizQuestion({
    required this.section,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.feedback,
  });
}

class GeneralQuizAttempt {
  final int scorePercent;
  final bool passed;
  final DateTime attemptedAt;
  final bool usedDeveloperSkip;

  const GeneralQuizAttempt({
    required this.scorePercent,
    required this.passed,
    required this.attemptedAt,
    this.usedDeveloperSkip = false,
  });

  factory GeneralQuizAttempt.fromJson(Map<String, dynamic> json) {
    return GeneralQuizAttempt(
      scorePercent: (json['scorePercent'] as num?)?.toInt() ?? 0,
      passed: json['passed'] == true,
      attemptedAt:
          DateTime.tryParse((json['attemptedAt'] ?? '').toString()) ??
          DateTime.now(),
      usedDeveloperSkip: json['usedDeveloperSkip'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scorePercent': scorePercent,
      'passed': passed,
      'attemptedAt': attemptedAt.toIso8601String(),
      'usedDeveloperSkip': usedDeveloperSkip,
    };
  }
}

class GeneralQuizStatus {
  final List<GeneralQuizAttempt> attempts;
  final int latestScore;
  final bool passed;
  final DateTime? passedAt;
  final bool finalPhaseEligibleByGeneralQuiz;

  const GeneralQuizStatus({
    this.attempts = const [],
    this.latestScore = 0,
    this.passed = false,
    this.passedAt,
    this.finalPhaseEligibleByGeneralQuiz = false,
  });

  factory GeneralQuizStatus.fromJson(Map<String, dynamic> json) {
    return GeneralQuizStatus(
      attempts: (json['attempts'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(GeneralQuizAttempt.fromJson)
          .toList(growable: false),
      latestScore: (json['latestScore'] as num?)?.toInt() ?? 0,
      passed: json['passed'] == true,
      passedAt: DateTime.tryParse((json['passedAt'] ?? '').toString()),
      finalPhaseEligibleByGeneralQuiz:
          json['finalPhaseEligibleByGeneralQuiz'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attempts': attempts.map((item) => item.toJson()).toList(),
      'latestScore': latestScore,
      'passed': passed,
      'passedAt': passedAt?.toIso8601String(),
      'finalPhaseEligibleByGeneralQuiz': finalPhaseEligibleByGeneralQuiz,
    };
  }
}
