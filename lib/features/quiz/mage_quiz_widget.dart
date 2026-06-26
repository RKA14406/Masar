import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class ImageQuizWidget extends StatelessWidget {
  final String task;
  final bool isMarkedComplete;
  final ValueChanged<bool>? onMarkedCompleteChanged;
  final TextEditingController explanationController;

  const ImageQuizWidget({
    super.key,
    required this.task,
    required this.isMarkedComplete,
    required this.explanationController,
    this.onMarkedCompleteChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment:
        isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            task,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 16),

          CheckboxListTile(
            value: isMarkedComplete,
            contentPadding: EdgeInsets.zero,
            controlAffinity: isArabic
                ? ListTileControlAffinity.trailing
                : ListTileControlAffinity.leading,
            title: Text(
              l.imageTaskCompleted,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
            ),
            onChanged: (value) =>
                onMarkedCompleteChanged?.call(value ?? false),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: explanationController,
            minLines: 4,
            maxLines: 8,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: l.imageExplainHint,
            ),
          ),
        ],
      ),
    );
  }
}