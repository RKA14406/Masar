class QuizQuestion {
  final String question;
  final List<String> choices;
  final int correctAnswerIndex;
  final String explanation;
  final String difficultyTag;

  const QuizQuestion({
    required this.question,
    required this.choices,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.difficultyTag,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final question = (json['question'] ?? '').toString().trim();
    if (question.isEmpty) {
      throw const FormatException('Quiz question text cannot be empty.');
    }

    final rawChoices = (json['choices'] as List<dynamic>? ?? const [])
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    if (rawChoices.length != 4) {
      throw const FormatException('Each question must contain exactly 4 choices.');
    }

    final correctIndexRaw = json['correct_answer_index'];
    final correctIndex = correctIndexRaw is int
        ? correctIndexRaw
        : int.tryParse(correctIndexRaw.toString()) ?? -1;

    if (correctIndex < 0 || correctIndex >= rawChoices.length) {
      throw const FormatException(
        'correct_answer_index must be between 0 and 3.',
      );
    }

    final explanation = (json['explanation'] ?? '').toString().trim();
    final difficultyTag = (json['difficulty_tag'] ?? 'medium')
        .toString()
        .trim()
        .toLowerCase();

    return QuizQuestion(
      question: question,
      choices: rawChoices,
      correctAnswerIndex: correctIndex,
      explanation: explanation,
      difficultyTag: difficultyTag.isEmpty ? 'medium' : difficultyTag,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'choices': choices,
      'correct_answer_index': correctAnswerIndex,
      'explanation': explanation,
      'difficulty_tag': difficultyTag,
    };
  }
}
