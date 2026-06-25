import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/phase0_mapping_service.dart';
import '../../core/services/progress_service.dart';
import '../../core/services/user_profile_service.dart';
import '../../core/widgets/app_drawer.dart';
import '../../l10n/app_localizations.dart';

import '../path_view/path_view_controller.dart';
import '../path_view/path_view_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProgressService _progressService = ProgressService();
  final Phase0MappingService _mappingService = Phase0MappingService();

  String? _college;
  String? _specialization;
  String? _collegeAr;
  String? _specializationAr;
  double _progress = 0;

  bool _loadingProgress = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final track = await _progressService.getSelectedTrack();

    if (track == null) {
      setState(() => _loadingProgress = false);
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
      _loadingProgress = false;
    });
  }

  Future<void> _openContinueLearning() async {
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

    await _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.profileTitle ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: theme.brightness == Brightness.dark
                ? [
              const Color(0xFF091321),
              const Color(0xFF0D1A2D),
              const Color(0xFF06101B),
            ]
                : [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<Map<String, dynamic>?>(
            future: UserProfileService().getCurrentUserProfile(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data;
              final username = data?['username'] ?? 'User';
              final age = data?['age']?.toString() ?? '-';
              final email = user?.email ?? data?['email'] ?? 'No email';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _profileCard(username, email, theme),
                    const SizedBox(height: 20),

                    _buildProgressCard(theme, l10n),

                    const SizedBox(height: 12),

                    _buildContinueLearningButton(theme, l10n),

                    const SizedBox(height: 20),

                    _InfoCard(
                      title: l10n.age ,
                      value: age,
                      icon: Icons.cake_outlined,
                      theme: theme,
                    ),

                    const SizedBox(height: 14),

                    _InfoCard(
                      title: l10n.accountStatus ,
                      value: l10n.active ,
                      icon: Icons.verified_user_outlined,
                      theme: theme,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _profileCard(String username, String email, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Icon(Icons.person,
              size: 80, color: theme.colorScheme.onSurface),
          const SizedBox(height: 16),
          Text(
            username,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(ThemeData theme, AppLocalizations l10n) {
    if (_loadingProgress) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_college == null) {
      return Text(
        l10n.noTrackSelected,
        style: theme.textTheme.bodyMedium,
      );
    }

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final displaySpecialization =
        isArabic ? (_specializationAr ?? _specialization!) : _specialization!;
    final displayCollege =
        isArabic ? (_collegeAr ?? _college!) : _college!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displaySpecialization,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            displayCollege,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (_progress / 100).clamp(0.0, 1.0),
          ),
          const SizedBox(height: 8),
          Text(
            '${l10n.progress}: ${_progress.toStringAsFixed(1)}%',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearningButton(
      ThemeData theme, AppLocalizations l10n) {
    if (_college == null || _specialization == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _openContinueLearning,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          l10n.continueLearning,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final ThemeData theme;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.iconTheme.color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodySmall),
              Text(
                value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}