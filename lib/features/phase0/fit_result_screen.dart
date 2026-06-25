import 'package:flutter/material.dart';

import '../../core/services/phase0_gemini_service.dart';
import '../../core/services/phase0_mapping_service.dart';
import '../../core/services/phase0_session_service.dart';
import '../../l10n/app_localizations.dart';
import 'specialty_recommendation_screen.dart';

class FitResultScreen extends StatefulWidget {
  const FitResultScreen({super.key});

  @override
  State<FitResultScreen> createState() => _FitResultScreenState();
}

class _FitResultScreenState extends State<FitResultScreen> {
  final Phase0SessionService _sessionService = Phase0SessionService();
  final Phase0GeminiService _geminiService = const Phase0GeminiService();
  final Phase0MappingService _mappingService = Phase0MappingService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Phase0SpecialtyRecommendation> _recommendations = const [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _sessionService.getInterestProfile();
      final summary = await _sessionService.getChatSummary();
      final aptitude = await _sessionService.getAptitudeSummary();
      final allowed = await _mappingService.getAllowedSpecialties();

      if (!mounted) return;

      final locale = Localizations.localeOf(context).languageCode;
      final language = locale == 'ar' ? 'Arabic' : 'English';

      final recommendations = await _geminiService.recommendFromDiscoveryPackage(
        interestProfile: profile ?? const {},
        chatSummary: summary ?? '',
        aptitudeSummary: aptitude ?? const {},
        allowedSpecialties: allowed,
        language: language,
      );

      await _sessionService.saveRecommendations(
        recommendations.map((item) => item.toJson()).toList(growable: false),
      );

      if (!mounted) return;

      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;

      setState(() {
        _errorMessage = l10n.fitResultError;
        _isLoading = false;
      });

      debugPrint('FitResultScreen error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      final theme = Theme.of(context);
      return Scaffold(
        appBar: AppBar(title: Text(l10n.fitResultTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loadRecommendations,
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SpecialtyRecommendationScreen(
      title: l10n.fitResultMainTitle,
      subtitle: l10n.fitResultSubtitle,
      recommendations: _recommendations,
      emptyMessage: l10n.fitResultEmpty,
    );
  }
}