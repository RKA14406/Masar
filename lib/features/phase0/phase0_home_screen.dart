import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../l10n/app_localizations.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_button.dart';
import '../../core/services/user_profile_service.dart';
import '../profile/profile_screen.dart';

import '../../core/services/phase0_gemini_service.dart';
import '../../core/services/phase0_mapping_service.dart';
import '../../core/services/progress_service.dart';

import '../path_view/path_view_controller.dart';
import '../path_view/path_view_screen.dart';

import 'specialty_recommendation_screen.dart';
import 'fit_questions_screen.dart';

class Phase0HomeScreen extends StatefulWidget {
  const Phase0HomeScreen({super.key});

  @override
  State<Phase0HomeScreen> createState() => _Phase0HomeScreenState();
}

class _Phase0HomeScreenState extends State<Phase0HomeScreen> {
  final ProgressService _progressService = ProgressService();
  final Phase0MappingService _mappingService = Phase0MappingService();

  String? _college;
  String? _specialization;
  String? _collegeAr;
  String? _specializationAr;
  double _progress = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final track = await _progressService.getSelectedTrack();

    if (track == null) {
      setState(() => _loading = false);
      return;
    }

    final controller = PathViewController(
      college: track.college,
      specialization: track.specialization,
    );

    final results = await Future.wait([
      controller.loadPath(),
      _mappingService.mapCollegeAndSpecialization(
        college: track.college,
        specialization: track.specialization,
      ),
    ]);

    final mapping = results[1] as Phase0MappedSpecialty?;

    setState(() {
      _college = track.college;
      _specialization = track.specialization;
      _collegeAr = mapping?.collegeTitleAr;
      _specializationAr = mapping?.datasetSpecializationAr;
      _progress = controller.progressPercent * 100;
      _loading = false;
    });
  }

  Future<void> _openContinue() async {
    if (_college == null || _specialization == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PathViewScreen(
          college: _college!,
          specialization: _specialization!,
        ),
      ),
    );

    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),

            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    /// 🔥 PROGRESS BLOCK

                    const SizedBox(height: 24),

                    _HeroSection(l10n: l10n),

                    const SizedBox(height: 24),

                    _DividerText(text: l10n.notSureYet),

                    const SizedBox(height: 16),

                    _QuizCard(
                      l10n: l10n,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FitQuestionsScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    _DividerText(text: l10n.yourProgress), // 👈 NEW TITLE

                    const SizedBox(height: 16),

                    _HomeProgressCard(
                      college: _college,
                      specialization: _specialization,
                      collegeAr: _collegeAr,
                      specializationAr: _specializationAr,
                      progress: _progress,
                      isLoading: _loading,
                      onContinue: _openContinue,
                      l10n: l10n,
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _HomeProgressCard extends StatelessWidget {
  final String? college;
  final String? specialization;
  final String? collegeAr;
  final String? specializationAr;
  final double progress;
  final bool isLoading;
  final VoidCallback onContinue;
  final AppLocalizations l10n;

  const _HomeProgressCard({
    required this.college,
    required this.specialization,
    this.collegeAr,
    this.specializationAr,
    required this.progress,
    required this.isLoading,
    required this.onContinue,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (college == null || specialization == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          l10n.noTrackSelected,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.start,
        ),
      );
    }

    final displaySpecialization =
        isArabic ? (specializationAr ?? specialization!) : specialization!;
    final displayCollege =
        isArabic ? (collegeAr ?? college!) : college!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            displaySpecialization,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 4),
          Text(
            displayCollege,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (progress / 100).clamp(0.0, 1.0),
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.progressLabel}: ${progress.toStringAsFixed(1)}%',
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              child: Text(l10n.continueLearning),
            ),
          ),
        ],
      ),
    );
  }
}
class _DividerText extends StatelessWidget {
  final String text;

  const _DividerText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(text),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
class _QuizCard extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _QuizCard({
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Icon(Icons.psychology_alt_rounded,
                color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(l10n.quickQuiz,
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(l10n.quizDescription,
                      style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Icon(
              isRTL
                  ? Icons.arrow_back_ios_new_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
class _HeroSection extends StatefulWidget {
  final AppLocalizations l10n;

  const _HeroSection({required this.l10n});

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection> {
  final TextEditingController controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() => _isLoading = true);

    final geminiService = const Phase0GeminiService();
    final mappingService = Phase0MappingService();
    final locale = Localizations.localeOf(context).languageCode;
    final language = locale == 'ar' ? 'Arabic' : 'English';

    try {
      final allowed = await mappingService.getAllowedSpecialties();

      final results = await geminiService.recommendFromFreeText(
        userDescription: text,
        allowedSpecialties: allowed,
        language: language,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SpecialtyRecommendationScreen(
            title: widget.l10n.suggestedSpecialties,
            subtitle: widget.l10n.choosePathSubtitle,
            recommendations: results,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          widget.l10n.whatDoYouWantToBecome,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: controller,
                hint: widget.l10n.aiInputHint,
              ),
            ),

            IconButton(
              onPressed: _submit,


    icon: Icon(
    isRTL ? Icons.arrow_back : Icons.arrow_forward,
    ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        AppButton(
          text: widget.l10n.startWithAI,
          isLoading: _isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }
}
class _TopBar extends StatelessWidget {
  const _TopBar();

  String _initials(String? username, String? email) {
    final src = (username != null && username.isNotEmpty)
        ? username
        : (email ?? '');
    if (src.isEmpty) return '?';
    final parts = src.trim().split(RegExp(r'[\s@._]+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return src[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = FirebaseAuth.instance.currentUser?.email;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              icon: const Icon(Icons.menu),
            ),
          ),
          const Expanded(
            child: Center(child: AppLogo(height: 100)),
          ),
          // Profile avatar
          FutureBuilder<Map<String, dynamic>?>(
            future: UserProfileService().getCurrentUserProfile(),
            builder: (context, snapshot) {
              final username =
                  snapshot.data?['username'] as String? ?? '';
              final initials = _initials(username, email);
              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProfileScreen()),
                ),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Center(
                    child: snapshot.connectionState ==
                            ConnectionState.waiting
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  theme.colorScheme.onPrimaryContainer,
                            ),
                          )
                        : Text(
                            initials,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
