import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/widgets/app_drawer.dart';
import '../../l10n/masar_text.dart';
import 'general_quiz_model.dart';
import 'general_quiz_service.dart';
import 'general_quiz_storage_service.dart';

class GeneralQuizScreen extends StatefulWidget {
  final String college;
  final String specialization;

  const GeneralQuizScreen({
    super.key,
    required this.college,
    required this.specialization,
  });

  @override
  State<GeneralQuizScreen> createState() => _GeneralQuizScreenState();
}

class _GeneralQuizScreenState extends State<GeneralQuizScreen> {
  static const String _developerBypassCode = '4406';

  final GeneralQuizService _quizService = GeneralQuizService();
  final GeneralQuizStorageService _storage = GeneralQuizStorageService();
  final ImagePicker _imagePicker = ImagePicker();

  final Map<String, int> _mcqAnswers = {};
  final Map<String, TextEditingController> _writtenControllers = {};
  final Map<String, String> _imagePaths = {};

  GeneralExam? _exam;
  GeneralQuizStatus? _status;
  GeneralQuizAttempt? _latestAttempt;
  GeneralExamEvaluation? _evaluation;
  bool _isGenerating = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStatusAndExam();
  }

  @override
  void dispose() {
    for (final controller in _writtenControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadStatusAndExam() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    final language = Localizations.localeOf(context).languageCode == 'ar'
        ? 'Arabic'
        : 'English';
    try {
      final status = await _storage.loadStatus(widget.specialization);
      final exam = await _quizService.generateExam(
        college: widget.college,
        specialization: widget.specialization,
        language: language,
      );

      if (!mounted) return;
      _resetAnswers(exam);
      setState(() {
        _status = status;
        _exam = exam;
        _isGenerating = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _exam = null;
        _errorMessage = error.toString();
        _isGenerating = false;
      });
    }
  }

  void _resetAnswers(GeneralExam exam) {
    for (final controller in _writtenControllers.values) {
      controller.dispose();
    }
    _mcqAnswers.clear();
    _writtenControllers.clear();
    _imagePaths.clear();

    for (final question in exam.questions) {
      if (question.type == GeneralExamQuestionType.written) {
        _writtenControllers[question.id] = TextEditingController();
      }
    }
  }

  Future<void> _pickImage(GeneralExamQuestion question) async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 2200,
      maxHeight: 2200,
    );
    if (picked == null || !mounted) return;
    setState(() => _imagePaths[question.id] = picked.path);
  }

  bool _isComplete(GeneralExam exam) {
    for (final question in exam.questions) {
      switch (question.type) {
        case GeneralExamQuestionType.mcq:
          if (!_mcqAnswers.containsKey(question.id)) return false;
          break;
        case GeneralExamQuestionType.written:
          if ((_writtenControllers[question.id]?.text.trim() ?? '').isEmpty) {
            return false;
          }
          break;
        case GeneralExamQuestionType.image:
          if ((_imagePaths[question.id] ?? '').isEmpty) return false;
          break;
      }
    }
    return true;
  }

  Future<void> _submit() async {
    final exam = _exam;
    if (exam == null || _isSubmitting) return;

    if (!_isComplete(exam)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            MasarText.t(
              context,
              'Answer every question before submitting.',
              'أجب عن كل الأسئلة قبل الإرسال.',
            ),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final writtenAnswers = _writtenControllers.map(
      (id, controller) => MapEntry(id, controller.text.trim()),
    );
    final submission = GeneralExamSubmission(
      mcqAnswers: Map.unmodifiable(_mcqAnswers),
      writtenAnswers: Map.unmodifiable(writtenAnswers),
      imagePaths: Map.unmodifiable(_imagePaths),
    );

    final language = Localizations.localeOf(context).languageCode == 'ar'
        ? 'Arabic'
        : 'English';
    try {
      final evaluation = await _quizService.gradeExam(
        exam: exam,
        submission: submission,
        college: widget.college,
        specialization: widget.specialization,
        language: language,
      );

      await _saveResult(
        scorePercent: evaluation.scorePercent,
        passed: evaluation.passed,
        evaluation: evaluation,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = error.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            MasarText.t(
              context,
              'Gemini could not grade this exam. Please retry.',
              'تعذر على Gemini تصحيح الاختبار. حاول مرة أخرى.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _saveResult({
    required int scorePercent,
    required bool passed,
    bool usedDeveloperSkip = false,
    GeneralExamEvaluation? evaluation,
  }) async {
    setState(() => _isSubmitting = true);
    final status = await _storage.saveAttempt(
      specialization: widget.specialization,
      scorePercent: scorePercent,
      passed: passed,
      usedDeveloperSkip: usedDeveloperSkip,
    );

    if (!mounted) return;
    setState(() {
      _status = status;
      _evaluation = evaluation;
      _latestAttempt = GeneralQuizAttempt(
        scorePercent: scorePercent,
        passed: passed,
        attemptedAt: DateTime.now(),
        usedDeveloperSkip: usedDeveloperSkip,
      );
      _isSubmitting = false;
    });
  }

  Future<void> _showDeveloperSkipDialog() async {
    final t = MasarText.t;
    var enteredCode = '';
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t(context, 'Developer bypass', 'تجاوز المطور')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t(
                  context,
                  'Enter the developer code to pass the General Quiz and unlock Final Phase eligibility.',
                  'أدخل رمز المطور لاجتياز الاختبار العام وفتح المرحلة النهائية.',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                autofocus: true,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: t(context, 'Developer code', 'رمز المطور'),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => enteredCode = value.trim(),
                onSubmitted: (value) {
                  Navigator.of(dialogContext).pop(value.trim());
                },
              ),
              const SizedBox(height: 10),
              Text(
                t(
                  context,
                  'This bypass does not mark subjects completed.',
                  'هذا التجاوز لا يضع المواد كمكتملة.',
                ),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(t(context, 'Cancel', 'إلغاء')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(enteredCode),
              child: Text(t(context, 'Skip Quiz', 'تجاوز الاختبار')),
            ),
          ],
        );
      },
    );

    if (!mounted || result == null || result.isEmpty) return;

    if (result != _developerBypassCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            MasarText.t(
              context,
              'Wrong developer code.',
              'رمز المطور غير صحيح.',
            ),
          ),
        ),
      );
      return;
    }

    await _saveResult(scorePercent: 100, passed: true, usedDeveloperSkip: true);
  }

  @override
  Widget build(BuildContext context) {
    final t = MasarText.t;
    final attempt = _latestAttempt;
    if (attempt != null) return _buildResult(attempt);

    final exam = _exam;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(t(context, 'General Quiz', 'الاختبار العام')),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _showDeveloperSkipDialog,
            child: Text(t(context, 'Developer Skip', 'تجاوز المطور')),
          ),
        ],
      ),
      body: _isGenerating
          ? _LoadingExam(major: widget.specialization)
          : exam == null
          ? _ErrorState(
              message: _errorMessage ?? 'Could not create the Gemini exam.',
              onRetry: _loadStatusAndExam,
            )
          : _buildExam(exam),
    );
  }

  Widget _buildExam(GeneralExam exam) {
    final t = MasarText.t;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (_status?.passed == true)
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_outlined),
              title: Text(
                t(
                  context,
                  'Final Phase already unlocked by General Quiz.',
                  'تم فتح المرحلة النهائية مسبقاً عبر الاختبار العام.',
                ),
              ),
              subtitle: Text(
                '${t(context, 'Latest score:', 'آخر نتيجة:')} ${_status!.latestScore}%',
              ),
            ),
          ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(exam.instructions),
                const SizedBox(height: 10),
                Text(
                  '${t(context, 'Major:', 'التخصص:')} ${widget.specialization}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '${t(context, 'Passing score:', 'درجة النجاح:')} ${exam.passingScore}%',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...exam.questions.asMap().entries.map(
          (entry) => _QuestionCard(
            number: entry.key + 1,
            question: entry.value,
            selectedMcq: _mcqAnswers[entry.value.id],
            writtenController: _writtenControllers[entry.value.id],
            imagePath: _imagePaths[entry.value.id],
            onMcqChanged: (value) {
              setState(() => _mcqAnswers[entry.value.id] = value);
            },
            onPickImage: () => _pickImage(entry.value),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _isSubmitting ? null : _submit,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome_rounded),
          label: Text(
            _isSubmitting
                ? t(context, 'Gemini is grading...', 'Gemini يصحح الاختبار...')
                : t(context, 'Submit to Gemini', 'إرسال إلى Gemini'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t(
            context,
            'Gemini grades your answers without marking subjects completed.',
            'Gemini يصحح إجاباتك دون وضع المواد كمكتملة.',
          ),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildResult(GeneralQuizAttempt attempt) {
    final passed = attempt.passed;
    final t = MasarText.t;
    final evaluation = _evaluation;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: Text(t(context, 'General Quiz', 'الاختبار العام'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    passed ? Icons.check_circle_outline : Icons.error_outline,
                    size: 52,
                    color: passed ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    passed
                        ? t(context, 'Passed', 'ناجح')
                        : t(context, 'Not passed yet', 'لم تنجح بعد'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${t(context, 'Score:', 'النتيجة:')} ${attempt.scorePercent}%',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    evaluation?.feedback ??
                        (passed
                            ? t(
                                context,
                                'Final Phase unlocked by General Quiz.',
                                'تم فتح المرحلة النهائية عبر الاختبار العام.',
                              )
                            : t(
                                context,
                                'You need 70% to pass. Review weak sections and try again.',
                                'تحتاج إلى 70% للنجاح. راجع الأقسام الضعيفة وحاول مرة أخرى.',
                              )),
                  ),
                  if (attempt.usedDeveloperSkip) ...[
                    const SizedBox(height: 8),
                    Text(
                      t(
                        context,
                        'Developer bypass was used. Subjects were not marked completed.',
                        'تم استخدام تجاوز المطور. لم يتم وضع المواد كمكتملة.',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (evaluation != null) ...[
            _ResultList(title: 'Strengths', values: evaluation.strengths),
            _ResultList(title: 'Weak areas', values: evaluation.weakAreas),
            _ResultList(title: 'Next steps', values: evaluation.nextSteps),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(context, passed),
            child: Text(
              t(context, 'Back to Learning Path', 'العودة إلى مسار التعلم'),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _latestAttempt = null;
                _evaluation = null;
              });
              _loadStatusAndExam();
            },
            child: Text(t(context, 'Generate New Exam', 'إنشاء اختبار جديد')),
          ),
        ],
      ),
    );
  }
}

class _LoadingExam extends StatelessWidget {
  final String major;

  const _LoadingExam({required this.major});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 18),
            Text(
              'Gemini is creating a full $major exam. This can take up to one minute...',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int number;
  final GeneralExamQuestion question;
  final int? selectedMcq;
  final TextEditingController? writtenController;
  final String? imagePath;
  final ValueChanged<int> onMcqChanged;
  final VoidCallback onPickImage;

  const _QuestionCard({
    required this.number,
    required this.question,
    required this.selectedMcq,
    required this.writtenController,
    required this.imagePath,
    required this.onMcqChanged,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question $number • ${question.section} • ${_typeLabel(question.type)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(question.prompt, style: theme.textTheme.titleMedium),
            const SizedBox(height: 14),
            switch (question.type) {
              GeneralExamQuestionType.mcq => _McqAnswer(
                question: question,
                selected: selectedMcq,
                onChanged: onMcqChanged,
              ),
              GeneralExamQuestionType.written => TextField(
                controller: writtenController,
                minLines: 5,
                maxLines: 10,
                decoration: const InputDecoration(
                  hintText: 'Write your answer here...',
                  border: OutlineInputBorder(),
                ),
              ),
              GeneralExamQuestionType.image => _ImageAnswer(
                imagePath: imagePath,
                onPickImage: onPickImage,
                rubric: question.rubric,
              ),
            },
          ],
        ),
      ),
    );
  }

  String _typeLabel(GeneralExamQuestionType type) {
    return switch (type) {
      GeneralExamQuestionType.mcq => 'MCQ',
      GeneralExamQuestionType.written => 'Written',
      GeneralExamQuestionType.image => 'Image upload',
    };
  }
}

class _McqAnswer extends StatelessWidget {
  final GeneralExamQuestion question;
  final int? selected;
  final ValueChanged<int> onChanged;

  const _McqAnswer({
    required this.question,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final isSelected = selected == entry.key;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onChanged(entry.key),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(entry.value)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ImageAnswer extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onPickImage;
  final List<String> rubric;

  const _ImageAnswer({
    required this.imagePath,
    required this.onPickImage,
    required this.rubric,
  });

  @override
  Widget build(BuildContext context) {
    final selected = imagePath?.isNotEmpty == true ? File(imagePath!) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (rubric.isNotEmpty) ...[
          Text('Rubric', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 6),
          ...rubric.map((item) => Text('• $item')),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: onPickImage,
          icon: const Icon(Icons.image_outlined),
          label: Text(selected == null ? 'Upload image' : 'Change image'),
        ),
        const SizedBox(height: 12),
        if (selected != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              selected,
              height: 210,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
      ],
    );
  }
}

class _ResultList extends StatelessWidget {
  final String title;
  final List<String> values;

  const _ResultList({required this.title, required this.values});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...values.map((value) => Text('• $value')),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text(
              'Masar will not use a mock exam here. Retry when Gemini is available, or use Developer Skip for testing.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
