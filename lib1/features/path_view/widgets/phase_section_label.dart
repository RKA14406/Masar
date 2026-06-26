import 'package:flutter/material.dart';

class PhaseSectionLabel extends StatelessWidget {
  final String title;
  final String subtitle;

  const PhaseSectionLabel({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF57D6FF), const Color(0xFFFFD54F)]
                    : [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDark
                      ? Colors.white60
                      : theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
