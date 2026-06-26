import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/services/gemini_quiz_service.dart';
import '../../../core/services/quiz_screen_security_service.dart';
import '../../../data/models/quiz_attempt_result_model.dart';
import '../../../data/models/quiz_models.dart';
import '../../../data/models/quiz_question_model.dart';
import '../../../data/models/subject_model.dart';
import '../../../core/services/gemini_image_quiz_service.dart';
import 'image_quiz_widget.dart';

Future<QuizAttemptResult?> showSubjectCompletionQuiz({
  required BuildContext context,
  required Subject subject,
  required String college,
  required String specialization,
  required String achievementsSummary,
}) {
  final languageCode = Localizations.localeOf(context).languageCode;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SubjectCompletionQuizSheet(
      subject: subject,
      college: college,
      specialization: specialization,
      achievementsSummary: achievementsSummary,
      languageCode: languageCode,
    ),
  );
}

class SubjectCompletionQuizSheet extends StatefulWidget {
  final Subject subject;
  final String college;
  final String specialization;
  final String achievementsSummary;
  final String languageCode;

  const SubjectCompletionQuizSheet({
    super.key,
    required this.subject,
    required this.college,
    required this.specialization,
    required this.achievementsSummary,
    required this.languageCode,
  });

  @override
  State<SubjectCompletionQuizSheet> createState() =>
      _SubjectCompletionQuizSheetState();
}

class _SubjectCompletionQuizSheetState
    extends State<SubjectCompletionQuizSheet> {
  final GeminiQuizService _service = const GeminiQuizService();
  final QuizScreenSecurityService _security = QuizScreenSecurityService();

  GeneratedQuiz? _quiz;
  bool _loading = true;

  int _currentIndex = 0;
  List<int?> _answers = [];

  final TextEditingController _writingController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    _security.startProtectedQuizSession();
    _loadQuiz();
  }

  @override
  void dispose() {
    _security.stopProtectedQuizSession();
    _writingController.dispose();
    super.dispose();
  }

  Future<void> _loadQuiz() async {
    final quiz = await _service.generateDynamicQuiz(
      subject: widget.subject,
      college: widget.college,
      specialization: widget.specialization,
      achievementsSummary: widget.achievementsSummary,
      language: widget.languageCode,
    );

    if (!mounted) return;

    setState(() {
      _quiz = quiz;
      _loading = false;

      if (quiz.type == QuizType.mcq) {
        _answers =
        List<int?>.filled(quiz.mcqQuestions?.length ?? 0, null);
      }
    });
  }

  void _finish({
    required bool passed,
    required int correctAnswers,
    required int totalQuestions,
  }) {
    final scorePercent = totalQuestions == 0
        ? 0.0
        : (correctAnswers / totalQuestions) * 100.0;

    Navigator.pop(
      context,
      QuizAttemptResult(
        passed: passed,
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        scorePercent: scorePercent,
        integrityFlags: 0,
        integrityPassed: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.9;

    return SafeArea(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius:
          const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _buildQuizBody(),
      ),
    );
  }

  Widget _buildQuizBody() {
    switch (_quiz!.type) {
      case QuizType.mcq:
        return _buildMCQ();
      case QuizType.writing:
        return _buildWriting();
      case QuizType.image:
        return _buildImage();
    }
  }

  // ========================= MCQ =========================

  Widget _buildMCQ() {
    final l = AppLocalizations.of(context)!;

    final questions = _quiz!.mcqQuestions!
        .map((q) => QuizQuestion.fromJson(q))
        .toList();

    final q = questions[_currentIndex];

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.quizQuestionProgress(
                      _currentIndex + 1, questions.length),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text(q.question),
                const SizedBox(height: 24),
                ...List.generate(q.choices.length, (i) {
                  return RadioListTile<int>(
                    value: i,
                    groupValue: _answers[_currentIndex],
                    onChanged: (v) {
                      setState(() {
                        _answers[_currentIndex] = v;
                      });
                    },
                    title: Text(q.choices[i]),
                  );
                }),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              if (_answers[_currentIndex] == null) return;

              if (_currentIndex < questions.length - 1) {
                setState(() => _currentIndex++);
                return;
              }

              int correct = 0;
              for (int i = 0; i < questions.length; i++) {
                if (_answers[i] ==
                    questions[i].correctAnswerIndex) {
                  correct++;
                }
              }

              _finish(
                passed:
                correct >= (questions.length * 0.6).ceil(),
                correctAnswers: correct,
                totalQuestions: questions.length,
              );
            },
            child: Text(
              _currentIndex == questions.length - 1
                  ? l.quizFinish
                  : l.quizNext,
            ),
          ),
        ),
      ],
    );
  }

  // ========================= WRITING =========================

  Widget _buildWriting() {
    final l = AppLocalizations.of(context)!;

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(_quiz!.writingPrompt ?? ''),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            children: [
              TextField(
                controller: _writingController,
                minLines: 4,
                maxLines: 6,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: l.quizWriteHint,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _finish(
                      passed: _writingController.text
                          .trim()
                          .isNotEmpty,
                      correctAnswers: 1,
                      totalQuestions: 1,
                    );
                  },
                  child: Text(l.quizSubmit),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ========================= IMAGE =========================

  Widget _buildImage() {
    final l = AppLocalizations.of(context)!;

    return StatefulBuilder(
      builder: (context, setLocalState) {
        bool isSubmitting = false;

        return Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ImageQuizWidget(
                task: _quiz!.imageTask ?? '',
                instructions: _quiz!.instructions,
                isSubmitting: isSubmitting,
                onSubmit: (imageFile) async {
                  setLocalState(() => isSubmitting = true);

                  try {
                    final evaluation =
                    await GeminiImageQuizService()
                        .evaluateImageSubmission(
                      subject: widget.subject,
                      college: widget.college,
                      specialization:
                      widget.specialization,
                      achievementsSummary:
                      widget.achievementsSummary,
                      instructions: _quiz!.instructions,
                      imageTask: _quiz!.imageTask ?? '',
                      rubric: _quiz!.imageRubric,
                      passingScore: _quiz!.passingScore,
                      imageFile: imageFile,
                      language: widget.languageCode,
                    );

                    _finish(
                      passed: evaluation.passed,
                      correctAnswers:
                      evaluation.passed ? 1 : 0,
                      totalQuestions: 1,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(evaluation.feedback)),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                        Text(l.imageGradingFailed(e.toString())),
                      ),
                    );
                  } finally {
                    setLocalState(() => isSubmitting = false);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ========================= HEADER =========================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.subject.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
