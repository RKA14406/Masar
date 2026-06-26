import '../../data/models/subject_model.dart';

class QuizAchievementBuilder {
  const QuizAchievementBuilder._();

  static String build({
    required List<Subject> allSubjects,
    required Set<String> completedSubjectCodes,
  }) {
    final completedSubjects = allSubjects
        .where((subject) => completedSubjectCodes.contains(subject.code))
        .toList();

    if (completedSubjects.isEmpty) {
      return 'The user has not completed any previous subjects yet.';
    }

    final completedNames = completedSubjects
        .map((subject) => '${subject.code} - ${subject.name}')
        .toList();

    final learnedSkills = <String>{};
    for (final subject in completedSubjects) {
      learnedSkills.addAll(subject.skills);
    }

    final skillSummary = learnedSkills.isEmpty
        ? 'No skills were saved for completed subjects yet.'
        : learnedSkills.take(20).join(', ');

    return '''
Completed subjects count: ${completedSubjects.length}
Completed subjects:
${completedNames.join('\n')}

Skills already achieved:
$skillSummary
''';
  }
}
