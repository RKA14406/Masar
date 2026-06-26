import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class AppSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBrand;

  const AppSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.showBrand = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final loc = AppLocalizations.of(context)!;

    return Align(
      alignment:
      isRTL ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
        isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // 🔥 Brand (Masar / مسار)
          if (showBrand)
            Text(
              loc.appName,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),

          if (showBrand) const SizedBox(height: 10),

          // 🔹 Main Title
          Text(
            title,
            textAlign: isRTL ? TextAlign.right : TextAlign.left,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          // 🔹 Subtitle
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: isRTL ? TextAlign.right : TextAlign.left,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}