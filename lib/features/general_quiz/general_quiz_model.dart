enum GeneralExamQuestionType { mcq, written, image }

class GeneralExam {
  final String title;
  final String instructions;
  final int passingScore;
  final List<GeneralExamQuestion> questions;

  const GeneralExam({
    required this.title,
    required this.instructions,
    required this.passingScore,
    required this.questions,
  });

  factory GeneralExam.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] as List<dynamic>? ?? const [];
    return GeneralExam(
      title: (json['title'] ?? 'General Quiz').toString().trim(),
      instructions: (json['instructions'] ?? 'Complete the exam carefully.')
          .toString()
          .trim(),
      passingScore: _intValue(
        json['passing_score'],
        fallback: 70,
      ).clamp(1, 100),
      questions: rawQuestions
          .whereType<Map<String, dynamic>>()
          .map(GeneralExamQuestion.fromJson)
          .where((question) => question.prompt.isNotEmpty)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'instructions': instructions,
      'passing_score': passingScore,
      'questions': questions.map((question) => question.toJson()).toList(),
    };
  }
}

class GeneralExamQuestion {
  final String id;
  final String section;
  final GeneralExamQuestionType type;
  final String prompt;
  final List<String> options;
  final String expectedAnswer;
  final List<String> rubric;
  final int points;

  const GeneralExamQuestion({
    required this.id,
    required this.section,
    required this.type,
    required this.prompt,
    this.options = const [],
    this.expectedAnswer = '',
    this.rubric = const [],
    this.points = 5,
  });

  factory GeneralExamQuestion.fromJson(Map<String, dynamic> json) {
    final type = _questionType((json['type'] ?? 'written').toString());
    final options = _stringList(json['options']);
    return GeneralExamQuestion(
      id: (json['id'] ?? '').toString().trim().isEmpty
          ? 'q_${json.hashCode.abs()}'
          : (json['id'] ?? '').toString().trim(),
      section: (json['section'] ?? 'Major Knowledge').toString().trim(),
      type: type,
      prompt: (json['prompt'] ?? json['question'] ?? '').toString().trim(),
      options: type == GeneralExamQuestionType.mcq
          ? options.take(4).toList(growable: false)
          : const [],
      expectedAnswer: (json['expected_answer'] ?? '').toString().trim(),
      rubric: _stringList(json['rubric']),
      points: _intValue(json['points'], fallback: 5).clamp(1, 20),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section': section,
      'type': type.name,
      'prompt': prompt,
      'options': options,
      'expected_answer': expectedAnswer,
      'rubric': rubric,
      'points': points,
    };
  }
}

class GeneralExamSubmission {
  final Map<String, int> mcqAnswers;
  final Map<String, String> writtenAnswers;
  final Map<String, String> imagePaths;

  const GeneralExamSubmission({
    this.mcqAnswers = const {},
    this.writtenAnswers = const {},
    this.imagePaths = const {},
  });
}

class GeneralExamEvaluation {
  final int scorePercent;
  final bool passed;
  final String feedback;
  final List<String> strengths;
  final List<String> weakAreas;
  final List<String> nextSteps;

  const GeneralExamEvaluation({
    required this.scorePercent,
    required this.passed,
    required this.feedback,
    this.strengths = const [],
    this.weakAreas = const [],
    this.nextSteps = const [],
  });

  factory GeneralExamEvaluation.fromJson(Map<String, dynamic> json) {
    final score = _intValue(json['score_percent'], fallback: 0).clamp(0, 100);
    final passedValue = json['passed'];
    final passed = passedValue is bool
        ? passedValue
        : passedValue.toString().trim().toLowerCase() == 'true';
    return GeneralExamEvaluation(
      scorePercent: score,
      passed: passed,
      feedback: (json['feedback'] ?? '').toString().trim(),
      strengths: _stringList(json['strengths']),
      weakAreas: _stringList(json['weak_areas']),
      nextSteps: _stringList(json['next_steps']),
    );
  }
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

GeneralExamQuestionType _questionType(String value) {
  switch (value.trim().toLowerCase()) {
    case 'mcq':
    case 'multiple_choice':
      return GeneralExamQuestionType.mcq;
    case 'image':
    case 'drawing':
      return GeneralExamQuestionType.image;
    case 'written':
    case 'text':
    case 'answer':
    default:
      return GeneralExamQuestionType.written;
  }
}

List<String> _stringList(dynamic value) {
  return (value as List<dynamic>? ?? const [])
      .map((item) => item.toString().trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}

int _intValue(dynamic value, {required int fallback}) {
  if (value is num) return value.round();
  return int.tryParse(value.toString()) ?? fallback;
}
