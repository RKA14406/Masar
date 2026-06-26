import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/user_profile_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_drawer.dart';
import '../../l10n/masar_text.dart';
import '../auth/auth_gate.dart';
import '../cv_generator/cv_builder_screen.dart';
import '../cv_generator/cv_preview_screen.dart';
import '../cv_generator/cv_storage_service.dart';
import '../settings/settings_screen.dart';
import 'personal_info_screen.dart';

class SevenSabakHubScreen extends StatelessWidget {
  const SevenSabakHubScreen({super.key});

  Future<void> _openCv(BuildContext context) async {
    final saved = await CvStorageService().loadCv();
    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => saved == null
            ? const CvBuilderScreen()
            : CvPreviewScreen(savedCv: saved),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    UserProfileService().clearCache();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = MasarText.t;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('7sabak')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '7sabak',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t(
              context,
              'Your personal center for profile details, app settings, and CV readiness.',
              'مركزك الشخصي للبيانات، الإعدادات، وتجهيز السيرة الذاتية.',
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          _HubCard(
            icon: Icons.person_outline,
            title: t(context, 'Personal Info', 'المعلومات الشخصية'),
            subtitle: t(
              context,
              'Update your name, major, skills, goals, country, enrollment, and optional gender.',
              'حدّث اسمك وتخصصك ومهاراتك وأهدافك وبلدك وبيانات التسجيل والجنس الاختياري.',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
              );
            },
          ),
          _HubCard(
            icon: Icons.settings_outlined,
            title: t(context, 'Settings', 'الإعدادات'),
            subtitle: t(
              context,
              'Change theme and language preferences.',
              'غيّر إعدادات المظهر واللغة.',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SettingsScreen(settingsService: SettingsService()),
                ),
              );
            },
          ),
          _HubCard(
            icon: Icons.description_outlined,
            title: t(context, 'Create Your CV', 'أنشئ سيرتك الذاتية'),
            subtitle: t(
              context,
              'Build an ATS-friendly student CV from Masar progress and your own inputs.',
              'أنشئ سيرة ذاتية مناسبة لأنظمة ATS من تقدمك في مسار وبياناتك.',
            ),
            onTap: () => _openCv(context),
          ),
          const SizedBox(height: 20),
          _HubCard(
            icon: Icons.logout_rounded,
            title: t(context, 'Logout', 'تسجيل الخروج'),
            subtitle: t(
              context,
              'Sign out of your Masar account securely.',
              'الخروج من حساب مسار بأمان.',
            ),
            iconColor: AppColors.error,
            textColor: AppColors.error,
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _HubCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Icon(icon, size: 30, color: iconColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}
