class ImageQuizEvaluation {
  final bool passed;
  final double scorePercent;
  final String feedback;
  final List<String> strengths;
  final List<String> issues;
  final List<String> rubricChecks;

  const ImageQuizEvaluation({
    required this.passed,
    required this.scorePercent,
    required this.feedback,
    required this.strengths,
    required this.issues,
    required this.rubricChecks,
  });

  factory ImageQuizEvaluation.fromJson(Map<String, dynamic> json) {
    double parseScore(dynamic value) {
      if (value is num) {
        return value.toDouble().clamp(0.0, 100.0);
      }
      return (double.tryParse(value.toString()) ?? 0.0).clamp(0.0, 100.0);
    }

    List<String> parseList(dynamic value) {
      return (value as List<dynamic>? ?? const [])
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }

    final score = parseScore(json['score_percent']);
    final passedValue = json['passed'];
    final passed = passedValue is bool
        ? passedValue
        : passedValue.toString().trim().toLowerCase() == 'true';

    return ImageQuizEvaluation(
      passed: passed,
      scorePercent: score,
      feedback: (json['feedback'] ?? '').toString().trim(),
      strengths: parseList(json['strengths']),
      issues: parseList(json['issues']),
      rubricChecks: parseList(json['rubric_checks']),
    );
  }
}

class ImageQuizPayload {
  final String instructions;
  final String imageTask;
  final List<String> rubric;
  final int passingScore;

  const ImageQuizPayload({
    required this.instructions,
    required this.imageTask,
    required this.rubric,
    required this.passingScore,
  });
}
