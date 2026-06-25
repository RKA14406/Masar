import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../core/services/phase0_gemini_service.dart';
import '../../core/services/phase0_mapping_service.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_button.dart';
import 'specialty_recommendation_screen.dart';

class KnowWhatIWantScreen extends StatefulWidget {
  final String userInput;

  const KnowWhatIWantScreen({
    super.key,
    required this.userInput,
  });

  @override
  State<KnowWhatIWantScreen> createState() =>
      _KnowWhatIWantScreenState();
}

class _KnowWhatIWantScreenState extends State<KnowWhatIWantScreen> {
  late final TextEditingController _controller;

  final Phase0GeminiService _geminiService = const Phase0GeminiService();
  final Phase0MappingService _mappingService = Phase0MappingService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.userInput);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final language = locale == 'ar' ? 'Arabic' : 'English';
    final text = _controller.text.trim();

    if (text.isEmpty) {
      setState(() {
        _errorMessage = l10n.emptyDescriptionError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      /// 🔹 Get allowed specialties
      final allowedSpecialties =
      await _mappingService.getAllowedSpecialties();

      if (allowedSpecialties.isEmpty) {
        throw Exception("No specialties found locally");
      }

      /// 🔹 Call Gemini
      final results = await _geminiService.recommendFromFreeText(
        userDescription: text,
        allowedSpecialties: allowedSpecialties,
        language: language,
      );

      if (!mounted) return;

      /// 🔹 Navigate to results
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SpecialtyRecommendationScreen(
            title: l10n.suggestedSpecialties,
            subtitle: l10n.choosePathSubtitle,
            recommendations: results,
          ),
        ),
      );
    } catch (e, stack) {
      /// 🔥 LOG REAL ERROR (console only)
      debugPrint("🔥 GEMINI ERROR: $e");
      debugPrint(stack.toString());

      if (!mounted) return;

      /// 🔹 Show clean message to user
      setState(() {
        _errorMessage = _mapErrorToMessage(e, l10n);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _mapErrorToMessage(Object e, AppLocalizations l10n) {
    final msg = e.toString();

    if (msg.contains('401') || msg.contains('403')) {
      return "API error — check your Gemini key.";
    }

    if (msg.contains('empty payload')) {
      return "AI returned no response.";
    }

    if (msg.contains('FormatException')) {
      return "AI response format error.";
    }

    if (msg.contains('no valid specialties')) {
      return "No matching career paths found.";
    }

    return l10n.genericError;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.iKnowWhatIWant),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment:
            isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              /// 🔹 Context Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.describeYourGoal,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.youCanEdit,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// 🔹 Input
              AppTextField(
                controller: _controller,
                hint: l10n.aiInputHint,
              ),

              const SizedBox(height: 12),

              /// 🔹 Error
              if (_errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 12),

              /// 🔹 Button
              AppButton(
                text: l10n.getSuggestions,
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
