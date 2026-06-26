import 'quiz_question_model.dart';

enum QuizType {
  mcq,
  writing,
  image,
}

class GeneratedQuiz {
  final QuizType type;
  final String instructions;
  final List<dynamic>? mcqQuestions;
  final String? writingPrompt;
  final String? imageTask;
  final List<String> imageRubric;
  final int passingScore;

  GeneratedQuiz({
    required this.type,
    required this.instructions,
    this.mcqQuestions,
    this.writingPrompt,
    this.imageTask,
    this.imageRubric = const [],
    this.passingScore = 60,
  });

  List<QuizQuestion> get parsedMcqQuestions {
    final raw = mcqQuestions ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(QuizQuestion.fromJson)
        .toList(growable: false);
  }
}

class QuizResult {
  final bool passed;
  final double? score;
  final String feedback;

  QuizResult({
    required this.passed,
    this.score,
    required this.feedback,
  });
}
