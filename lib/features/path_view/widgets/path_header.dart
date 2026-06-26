import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class PathHeader extends StatelessWidget {
  final String college;
  final String specialization;
  final String? collegeAr;
  final String? specializationAr;
  final double progress;

  const PathHeader({
    super.key,
    required this.college,
    required this.specialization,
    this.collegeAr,
    this.specializationAr,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final progressPercent = (progress * 100).round();

    final displayCollege =
        isArabic ? (collegeAr ?? college) : college;
    final displaySpecialization =
        isArabic ? (specializationAr ?? specialization) : specialization;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF162338), const Color(0xFF0E1C2F)]
                : [
                    theme.colorScheme.surfaceContainerHighest,
                    theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.7),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isDark
                ? const Color(0xFF57D6FF).withValues(alpha: 0.18)
                : theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayCollege,
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF8EDFFF)
                    : theme.colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              displaySpecialization,
              style: TextStyle(
                color: isDark ? Colors.white : theme.colorScheme.onSurface,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.pathHeaderHint,
              style: TextStyle(
                color: isDark
                    ? Colors.white70
                    : theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                valueColor: AlwaysStoppedAnimation(
                  isDark
                      ? const Color(0xFFFFD54F)
                      : theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.progressLabel}: $progressPercent%',
              style: TextStyle(
                color: isDark
                    ? Colors.white70
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
