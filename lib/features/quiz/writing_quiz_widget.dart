import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class WritingQuizWidget extends StatelessWidget {
  final String prompt;
  final TextEditingController controller;
  final String? hintText;

  const WritingQuizWidget({
    super.key,
    required this.prompt,
    required this.controller,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    return SafeArea(
      child: Column(
        children: [
          // 🔹 SCROLLABLE PROMPT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    prompt,
                    textAlign:
                    isArabic ? TextAlign.right : TextAlign.left,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),

          // 🔹 INPUT (FIXED BOTTOM)
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: TextField(
              controller: controller,
              minLines: 4,
              maxLines: 6,
              textAlign:
              isArabic ? TextAlign.right : TextAlign.left,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: hintText ?? l.quizWriteHint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}