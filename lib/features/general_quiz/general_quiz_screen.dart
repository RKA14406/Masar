import 'package:flutter/material.dart';

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

  late final List<GeneralQuizQuestion> _questions;
  final Map<int, int> _answers = {};
  int _index = 0;
  bool _isSaving = false;
  GeneralQuizStatus? _status;
  GeneralQuizAttempt? _latestAttempt;

  @override
  void initState() {
    super.initState();
    _questions = _quizService.questionsFor(widget.specialization);
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final status = await _storage.loadStatus(widget.specialization);
    if (!mounted) return;
    setState(() => _status = status);
  }

  Future<void> _submit() async {
    if (_answers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            MasarText.t(
              context,
              'Answer all questions first.',
              'أجب عن جميع الأسئلة أولاً.',
            ),
          ),
        ),
      );
      return;
    }

    final correct = _questions.asMap().entries.where((entry) {
      return _answers[entry.key] == entry.value.correctIndex;
    }).length;
    final score = ((correct / _questions.length) * 100).round();
    await _saveResult(scorePercent: score, passed: score >= 70);
  }

  Future<void> _saveResult({
    required int scorePercent,
    required bool passed,
    bool usedDeveloperSkip = false,
  }) async {
    setState(() => _isSaving = true);
    final status = await _storage.saveAttempt(
      specialization: widget.specialization,
      scorePercent: scorePercent,
      passed: passed,
      usedDeveloperSkip: usedDeveloperSkip,
    );

    if (!mounted) return;
    setState(() {
      _status = status;
      _latestAttempt = GeneralQuizAttempt(
        scorePercent: scorePercent,
        passed: passed,
        attemptedAt: DateTime.now(),
        usedDeveloperSkip: usedDeveloperSkip,
      );
      _isSaving = false;
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
                  'أدخل رمز المطور لاجتياز الاختبار العام وفتح أهلية المرحلة النهائية.',
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
                style: TextStyle(fontSize: 12, color: Colors.black54),
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

    final question = _questions[_index];
    final selected = _answers[_index];
    final isLast = _index == _questions.length - 1;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(t(context, 'General Quiz', 'الاختبار العام')),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _showDeveloperSkipDialog,
            child: Text(t(context, 'Developer Skip', 'تجاوز المطور')),
          ),
        ],
      ),
      body: ListView(
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
          Text(
            '${t(context, 'Question', 'السؤال')} ${_index + 1} ${t(context, 'of', 'من')} ${_questions.length}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            question.section,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.question,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ...question.options.asMap().entries.map((entry) {
                    final isSelected = selected == entry.key;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() => _answers[_index] = entry.key);
                        },
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
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _index == 0
                      ? null
                      : () => setState(() => _index -= 1),
                  child: Text(t(context, 'Back', 'رجوع')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _isSaving
                      ? null
                      : isLast
                      ? _submit
                      : () => setState(() => _index += 1),
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          isLast
                              ? t(context, 'Submit', 'إرسال')
                              : t(context, 'Next', 'التالي'),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResult(GeneralQuizAttempt attempt) {
    final passed = attempt.passed;
    final t = MasarText.t;
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
                    passed
                        ? t(
                            context,
                            'Final Phase unlocked by General Quiz.',
                            'تم فتح المرحلة النهائية عبر الاختبار العام.',
                          )
                        : t(
                            context,
                            'You need 70% to pass. Review weak sections and try again.',
                            'تحتاج إلى 70% للنجاح. راجع الأقسام الضعيفة وحاول مرة أخرى.',
                          ),
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
                _answers.clear();
                _index = 0;
                _latestAttempt = null;
              });
            },
            child: Text(t(context, 'Retake Quiz', 'إعادة الاختبار')),
          ),
        ],
      ),
    );
  }
}
