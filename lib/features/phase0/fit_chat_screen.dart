import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import '../../core/services/phase0_gemini_service.dart';
import '../../core/services/phase0_mapping_service.dart';
import '../../core/services/phase0_session_service.dart';
import '../../core/theme/app_colors.dart';
import 'fit_quiz_screen.dart';

class FitChatScreen extends StatefulWidget {
  const FitChatScreen({super.key});

  @override
  State<FitChatScreen> createState() => _FitChatScreenState();
}

class _FitChatScreenState extends State<FitChatScreen> {
  final Phase0SessionService _sessionService = Phase0SessionService();
  final Phase0GeminiService _geminiService = const Phase0GeminiService();
  final Phase0MappingService _mappingService = Phase0MappingService();
  final TextEditingController _controller = TextEditingController();

  List<String> _questions = const [];
  final List<Map<String, dynamic>> _transcript = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  int _currentIndex = 0;
  String? _errorMessage;

  static const List<String> _fallbackQuestionsEn = [
    'Which college direction currently feels most attractive to you, even if you are not fully sure yet, and why?',
    'Which subjects give you more energy: math and physics, chemistry and biology, finance and business, or design and visual work?',
    'Do you see yourself more in a lab, a technical/software team, a finance or business environment, or a design/architecture setting?',
    'Would you rather analyze numbers and risk, investigate scientific ideas, build technical solutions, or design spaces and experiences?',
    'What kind of future work would make you feel proud every day?',
  ];

  static const List<String> _fallbackQuestionsAr = [
    'أي اتجاه كلية يبدو الأكثر جاذبية لك حالياً، حتى لو لم تكن متأكداً تماماً، ولماذا؟',
    'أي المواد تمنحك طاقة أكبر: الرياضيات والفيزياء، أم الكيمياء والأحياء، أم المالية والأعمال، أم التصميم والعمل البصري؟',
    'هل ترى نفسك أكثر في مختبر، أم ضمن فريق تقني/برمجي، أم في بيئة مالية أو أعمال، أم في إعداد التصميم والعمارة؟',
    'هل تفضل تحليل الأرقام والمخاطر، أم التحقيق في الأفكار العلمية، أم بناء حلول تقنية، أم تصميم الفضاءات والتجارب؟',
    'أي نوع من العمل المستقبلي سيجعلك تشعر بالفخر كل يوم؟',
  ];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final profile = await _sessionService.getInterestProfile();
      final allowed = await _mappingService.getAllowedSpecialties();
      if (!mounted) return;

      final locale = Localizations.localeOf(context).languageCode;
      final language = locale == 'ar' ? 'Arabic' : 'English';
      final questions = await _geminiService
          .buildGuidedChatQuestions(
            interestProfile: profile ?? const {},
            allowedSpecialties: allowed,
            language: language,
          )
          .timeout(const Duration(seconds: 10));

      if (!mounted) return;

      setState(() {
        _questions = questions.isNotEmpty ? questions : _fallbackFor(locale);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final locale = Localizations.localeOf(context).languageCode;
      setState(() {
        _questions = _fallbackFor(locale);
        _isLoading = false;
        _errorMessage = 'fallback';
      });
    }
  }

  List<String> _fallbackFor(String locale) =>
      locale == 'ar' ? _fallbackQuestionsAr : _fallbackQuestionsEn;

  Future<void> _submitAnswer() async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final language = locale == 'ar' ? 'Arabic' : 'English';
    final answer = _controller.text.trim();
    if (answer.isEmpty || _isSubmitting || _questions.isEmpty) return;

    final question = _questions[_currentIndex];

    setState(() {
      _transcript.add({'role': 'assistant', 'text': question});
      _transcript.add({'role': 'user', 'text': answer});
      _controller.clear();
    });

    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex += 1);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final summary = await _geminiService.summarizeDiscoveryChat(
        transcript: _transcript,
        language: language,
      );

      await _sessionService.saveChatQuestions(_questions);
      await _sessionService.saveChatTranscript(_transcript);
      await _sessionService.saveChatSummary(summary);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      Navigator.push(context, MaterialPageRoute(builder: (_) => const FitQuizScreen()));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = l10n.fitChatFinalizeError;
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.fitChatSummaryFailed(error.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.fitChatTitle)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                          l10n.fitChatProgress(_currentIndex + 1, _questions.length),
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(l10n.fitChatDescription, style: theme.textTheme.bodyMedium),
                        if (_errorMessage != null && _errorMessage == 'fallback') ...[
                          const SizedBox(height: 10),
                          Text(
                            l10n.fitChatFallbackError,
                            style: TextStyle(
                              color: isDark ? const Color(0xFFFFD98A) : AppColors.warning,
                            ),
                          ),
                        ] else if (_errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _errorMessage!,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      for (final entry in _transcript)
                        _ChatBubble(
                          text: entry['text'].toString(),
                          isUser: entry['role'] == 'user',
                        ),
                      _ChatBubble(
                        text: _questions[_currentIndex],
                        isUser: false,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          minLines: 2,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: l10n.fitChatHint,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 56,
                        child: FilledButton(
                          onPressed: _isSubmitting ? null : _submitAnswer,
                          child: _isSubmitting
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.2))
                              : Text(_currentIndex == _questions.length - 1 ? l10n.finish : l10n.next),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: isUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isUser
              ? (isDark ? AppColors.primary.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.12))
              : theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUser ? AppColors.primary.withValues(alpha: 0.4) : theme.dividerColor,
          ),
        ),
        child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(height: 1.45)),
      ),
    );
  }
}
