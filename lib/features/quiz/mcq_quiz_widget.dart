import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import '../../data/models/quiz_question_model.dart';

class McqQuizWidget extends StatefulWidget {
  final List<QuizQuestion> questions;
  final ValueChanged<List<int?>>? onAnswersChanged;

  const McqQuizWidget({
    super.key,
    required this.questions,
    this.onAnswersChanged,
  });

  @override
  State<McqQuizWidget> createState() => _McqQuizWidgetState();
}

class _McqQuizWidgetState extends State<McqQuizWidget> {
  late final List<int?> _answers;

  @override
  void initState() {
    super.initState();
    _answers = List<int?>.filled(widget.questions.length, null);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    if (widget.questions.isEmpty) {
      return Center(
        child: Text(
          l.noQuestionsAvailable,
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      itemCount: widget.questions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final question = widget.questions[index];

        return Column(
          crossAxisAlignment:
          isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. ${question.question}',
              textAlign:
              isArabic ? TextAlign.right : TextAlign.left,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ...List.generate(question.choices.length, (choiceIndex) {
              return RadioListTile<int>(
                value: choiceIndex,
                groupValue: _answers[index],
                contentPadding: EdgeInsets.zero,
                controlAffinity: isArabic
                    ? ListTileControlAffinity.trailing
                    : ListTileControlAffinity.leading,
                title: Text(
                  question.choices[choiceIndex],
                  textAlign:
                  isArabic ? TextAlign.right : TextAlign.left,
                ),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() => _answers[index] = value);

                  widget.onAnswersChanged
                      ?.call(List<int?>.from(_answers));
                },
              );
            }),
          ],
        );
      },
    );
  }
}