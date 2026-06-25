import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/services/phase0_session_service.dart';
import '../../core/services/quiz_screen_security_service.dart';
import 'fit_result_screen.dart';

class FitQuizScreen extends StatefulWidget {
  const FitQuizScreen({super.key});

  @override
  State<FitQuizScreen> createState() => _FitQuizScreenState();
}

class _FitQuizScreenState extends State<FitQuizScreen> {
  final Phase0SessionService _sessionService = Phase0SessionService();
  final QuizScreenSecurityService _security = QuizScreenSecurityService();

  static const List<_AptitudeQuestion> _questions = [
    _AptitudeQuestion(
      question: 'A company buys equipment for 12,000 JOD and expects a salvage value of 2,000 JOD after 5 years. Using straight-line depreciation, what is the annual depreciation expense?',
      questionAr: 'اشترت شركة معدات بـ 12,000 دينار وتتوقع قيمة متبقية 2,000 دينار بعد 5 سنوات. باستخدام الإهلاك القسط الثابت، ما مصروف الإهلاك السنوي؟',
      category: 'finance_score',
      answers: ['1,600 JOD', '2,000 JOD', '2,400 JOD', '2,800 JOD'],
      answersAr: ['1,600 دينار', '2,000 دينار', '2,400 دينار', '2,800 دينار'],
      correctIndex: 1,
    ),
    _AptitudeQuestion(
      question: 'If f(x) = 2x² - 3x + 1, what is f(3)?',
      questionAr: 'إذا كانت f(x) = 2x² - 3x + 1، فما قيمة f(3)؟',
      category: 'math_score',
      answers: ['8', '10', '12', '14'],
      answersAr: ['8', '10', '12', '14'],
      correctIndex: 1,
    ),
    _AptitudeQuestion(
      question: 'A car increases its speed uniformly from 10 m/s to 22 m/s in 4 seconds. What is its acceleration?',
      questionAr: 'سيارة تزيد سرعتها بانتظام من 10 م/ث إلى 22 م/ث في 4 ثوانٍ. ما تسارعها؟',
      category: 'physics_score',
      answers: ['2 m/s²', '3 m/s²', '4 m/s²', '5 m/s²'],
      answersAr: ['2 م/ث²', '3 م/ث²', '4 م/ث²', '5 م/ث²'],
      correctIndex: 1,
    ),
    _AptitudeQuestion(
      question: 'What is the molar mass of H₂SO₄?',
      questionAr: 'ما الكتلة المولية لـ H₂SO₄؟',
      category: 'chemistry_score',
      answers: ['66 g/mol', '82 g/mol', '98 g/mol', '118 g/mol'],
      answersAr: ['66 غ/مول', '82 غ/مول', '98 غ/مول', '118 غ/مول'],
      correctIndex: 2,
    ),
    _AptitudeQuestion(
      question: 'If revenue is 90,000 and total cost is 63,000, what is the profit margin on revenue?',
      questionAr: 'إذا كانت الإيرادات 90,000 والتكلفة الإجمالية 63,000، فما هامش الربح على الإيرادات؟',
      category: 'finance_score',
      answers: ['20%', '25%', '30%', '42.9%'],
      answersAr: ['20%', '25%', '30%', '42.9%'],
      correctIndex: 2,
    ),
    _AptitudeQuestion(
      question: 'Solve: 3x - 7 = 14',
      questionAr: 'حل: 3x - 7 = 14',
      category: 'math_score',
      answers: ['5', '6', '7', '8'],
      answersAr: ['5', '6', '7', '8'],
      correctIndex: 2,
    ),
    _AptitudeQuestion(
      question: 'What is the equivalent resistance of two resistors 6Ω and 3Ω connected in parallel?',
      questionAr: 'ما المقاومة المكافئة لمقاومتين 6Ω و 3Ω متصلتين على التوازي؟',
      category: 'physics_score',
      answers: ['1Ω', '2Ω', '3Ω', '9Ω'],
      answersAr: ['1Ω', '2Ω', '3Ω', '9Ω'],
      correctIndex: 1,
    ),
    _AptitudeQuestion(
      question: 'Which statement is correct about pH?',
      questionAr: 'أي من العبارات التالية صحيحة بشأن درجة الحموضة pH؟',
      category: 'chemistry_score',
      answers: [
        'A solution with pH 2 is less acidic than pH 6',
        'A solution with pH 7 is neutral',
        'A solution with pH 10 is strongly acidic',
        'pH does not relate to hydrogen ion concentration',
      ],
      answersAr: [
        'محلول بـ pH 2 أقل حمضية من pH 6',
        'محلول بـ pH 7 متعادل',
        'محلول بـ pH 10 حمضي بشدة',
        'درجة pH لا علاقة لها بتركيز أيونات الهيدروجين',
      ],
      correctIndex: 1,
    ),
    _AptitudeQuestion(
      question: 'An investment grows from 5,000 to 5,750. What is the percentage increase?',
      questionAr: 'نمت استثمارات من 5,000 إلى 5,750. ما نسبة الزيادة؟',
      category: 'finance_score',
      answers: ['10%', '12%', '15%', '17.5%'],
      answersAr: ['10%', '12%', '15%', '17.5%'],
      correctIndex: 2,
    ),
    _AptitudeQuestion(
      question: 'What is the slope of the line passing through (2, 3) and (6, 11)?',
      questionAr: 'ما ميل الخط المار بالنقطتين (2, 3) و (6, 11)؟',
      category: 'math_score',
      answers: ['1', '2', '3', '4'],
      answersAr: ['1', '2', '3', '4'],
      correctIndex: 1,
    ),
    _AptitudeQuestion(
      question: 'A force of 20 N acts on an object of mass 4 kg. What is the acceleration?',
      questionAr: 'قوة 20 نيوتن تؤثر على جسم كتلته 4 كغم. ما تسارعه؟',
      category: 'physics_score',
      answers: ['2 m/s²', '4 m/s²', '5 m/s²', '8 m/s²'],
      answersAr: ['2 م/ث²', '4 م/ث²', '5 م/ث²', '8 م/ث²'],
      correctIndex: 2,
    ),
    _AptitudeQuestion(
      question: 'How many moles are in 18 g of water (H₂O)?',
      questionAr: 'كم عدد المولات في 18 غ من الماء (H₂O)؟',
      category: 'chemistry_score',
      answers: ['0.5 mol', '1 mol', '1.5 mol', '2 mol'],
      answersAr: ['0.5 مول', '1 مول', '1.5 مول', '2 مول'],
      correctIndex: 1,
    ),
    _AptitudeQuestion(
      question: 'If an item costs 80 JOD after a 20% discount, what was its original price?',
      questionAr: 'إذا تكلّف صنف 80 ديناراً بعد خصم 20%، فما سعره الأصلي؟',
      category: 'finance_score',
      answers: ['90 JOD', '96 JOD', '100 JOD', '120 JOD'],
      answersAr: ['90 دينار', '96 دينار', '100 دينار', '120 دينار'],
      correctIndex: 2,
    ),
    _AptitudeQuestion(
      question: 'What is the value of 2⁵ × 2²?',
      questionAr: 'ما قيمة 2⁵ × 2²؟',
      category: 'math_score',
      answers: ['32', '64', '128', '256'],
      answersAr: ['32', '64', '128', '256'],
      correctIndex: 2,
    ),
    _AptitudeQuestion(
      question: 'Which quantity is a vector?',
      questionAr: 'أي من الكميات التالية كمية متجهة؟',
      category: 'physics_score',
      answers: ['Speed', 'Distance', 'Mass', 'Velocity'],
      answersAr: ['السرعة السلمية', 'المسافة', 'الكتلة', 'السرعة المتجهة'],
      correctIndex: 3,
    ),
    _AptitudeQuestion(
      question: 'Which bond type usually forms between sodium and chlorine in NaCl?',
      questionAr: 'أي نوع من الروابط يتشكل عادةً بين الصوديوم والكلور في NaCl؟',
      category: 'chemistry_score',
      answers: ['Covalent bond', 'Hydrogen bond', 'Ionic bond', 'Metallic bond'],
      answersAr: ['رابطة تساهمية', 'رابطة هيدروجينية', 'رابطة أيونية', 'رابطة فلزية'],
      correctIndex: 2,
    ),
  ];

  final Map<int, int> _selectedAnswers = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _security.startProtectedQuizSession();
  }

  @override
  void dispose() {
    _security.stopProtectedQuizSession();
    super.dispose();
  }

  Future<void> _finishQuiz() async {
    final l10n = AppLocalizations.of(context)!;

    if (_selectedAnswers.length != _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.answerAllQuizFirst)),
      );
      return;
    }

    setState(() => _isSaving = true);

    final categoryTotals = <String, int>{
      'finance_score': 0, 'math_score': 0,
      'physics_score': 0, 'chemistry_score': 0,
    };
    final categoryCorrect = <String, int>{
      'finance_score': 0, 'math_score': 0,
      'physics_score': 0, 'chemistry_score': 0,
    };
    int totalCorrect = 0;

    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      categoryTotals.update(q.category, (v) => v + 1);
      if (_selectedAnswers[i] == q.correctIndex) {
        totalCorrect += 1;
        categoryCorrect.update(q.category, (v) => v + 1);
      }
    }

    final summary = <String, dynamic>{
      'total_questions': _questions.length,
      'correct_answers': totalCorrect,
      'score_percent': double.parse(((totalCorrect / _questions.length) * 100).toStringAsFixed(1)),
      'finance_score': _ratio(categoryCorrect['finance_score']!, categoryTotals['finance_score']!),
      'math_score': _ratio(categoryCorrect['math_score']!, categoryTotals['math_score']!),
      'physics_score': _ratio(categoryCorrect['physics_score']!, categoryTotals['physics_score']!),
      'chemistry_score': _ratio(categoryCorrect['chemistry_score']!, categoryTotals['chemistry_score']!),
      'completed_at': DateTime.now().toIso8601String(),
    };

    try {
      await _sessionService.saveAptitudeSummary(summary);
      if (!mounted) return;
      setState(() => _isSaving = false);
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FitResultScreen()));
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fitQuizSaveError(error))),
      );
    }
  }

  double _ratio(int correct, int total) {
    if (total == 0) return 0;
    return double.parse((correct / total).toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.fitQuizTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.fitQuizHeader,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.fitQuizSubtitle, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              itemCount: _questions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final q = _questions[index];
                return _QuizQuestionCard(
                  index: index + 1,
                  question: q,
                  selectedIndex: _selectedAnswers[index],
                  isArabic: isArabic,
                  onSelected: (v) => setState(() => _selectedAnswers[index] = v),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _isSaving ? null : _finishQuiz,
                child: _isSaving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.2))
                    : Text(l10n.fitQuizFinishButton),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizQuestionCard extends StatelessWidget {
  final int index;
  final _AptitudeQuestion question;
  final int? selectedIndex;
  final bool isArabic;
  final ValueChanged<int> onSelected;

  const _QuizQuestionCard({
    required this.index,
    required this.question,
    required this.selectedIndex,
    required this.isArabic,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final answers = isArabic ? question.answersAr : question.answers;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.questionLabel(index),
            style: theme.textTheme.labelMedium?.copyWith(
              color: const Color(0xFFFFD98A),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic ? question.questionAr : question.question,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, height: 1.35),
          ),
          const SizedBox(height: 14),
          ...List.generate(answers.length, (answerIndex) {
            final isSelected = selectedIndex == answerIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onSelected(answerIndex),
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isSelected
                        ? const Color(0xFFFFD98A).withValues(alpha: isDark ? 0.15 : 0.1)
                        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFFD98A) : theme.dividerColor,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(answers[answerIndex], style: theme.textTheme.bodyMedium),
                      ),
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? const Color(0xFFFFD98A) : theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AptitudeQuestion {
  final String question;
  final String questionAr;
  final String category;
  final List<String> answers;
  final List<String> answersAr;
  final int correctIndex;

  const _AptitudeQuestion({
    required this.question,
    required this.questionAr,
    required this.category,
    required this.answers,
    required this.answersAr,
    required this.correctIndex,
  });
}
