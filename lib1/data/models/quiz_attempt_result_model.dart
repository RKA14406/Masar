class QuizAttemptResult {
  final bool passed;
  final int correctAnswers;
  final int totalQuestions;
  final double scorePercent;
  final int integrityFlags;
  final bool integrityPassed;

  const QuizAttemptResult({
    required this.passed,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.scorePercent,
    required this.integrityFlags,
    required this.integrityPassed,
  });

  int get requiredCorrectAnswers => (totalQuestions * 0.6).ceil();
}
