import 'package:flutter/material.dart';

import '../../../data/models/subject_model.dart';
import '../../../l10n/masar_text.dart';
import '../path_view_controller.dart';

class SelectedSubjectPanel extends StatelessWidget {
  final Subject? subject;
  final NodeVisualState? state;
  final List<Subject> missingSubjects;
  final VoidCallback? onOpenDetails;

  const SelectedSubjectPanel({
    super.key,
    required this.subject,
    required this.state,
    required this.missingSubjects,
    required this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (subject == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final displayName = subject!.localizedName(context);
    final t = MasarText.t;

    final status = switch (state) {
      NodeVisualState.completed => t(context, 'Completed', 'مكتمل'),
      NodeVisualState.unlocked => t(context, 'Unlocked', 'متاح'),
      NodeVisualState.locked => t(context, 'Locked', 'مغلق'),
      null => t(context, 'Unknown', 'غير معروف'),
    };

    final lockedReason = missingSubjects.isEmpty
        ? t(
            context,
            'All prerequisites completed.',
            'تم إكمال جميع المتطلبات السابقة.',
          )
        : '${t(context, 'Needs:', 'يحتاج إلى:')} ${missingSubjects.map((s) => s.localizedName(context)).join(', ')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName,
              style: TextStyle(
                color: isDark ? Colors.white : theme.colorScheme.onSurface,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${subject!.code} • $status',
              style: TextStyle(
                color: isDark
                    ? Colors.white70
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              lockedReason,
              style: TextStyle(
                color: isDark
                    ? Colors.white60
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton(
                onPressed: onOpenDetails,
                child: Text(t(context, 'Open Details', 'فتح التفاصيل')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
