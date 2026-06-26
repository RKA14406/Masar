import 'cv_model.dart';

class AtsScoreResult {
  final int score;
  final List<String> tips;

  const AtsScoreResult({required this.score, required this.tips});
}

class AtsScoreService {
  const AtsScoreService();

  AtsScoreResult evaluate(CvInput input, GeneratedCv cv) {
    var score = 0;
    final tips = <String>[];

    if (input.fullName.trim().isNotEmpty) {
      score += 10;
    } else {
      tips.add('Add your full name.');
    }

    if (input.email.trim().isNotEmpty) {
      score += 10;
    } else {
      tips.add('Add your email address.');
    }

    if (input.phone.trim().isNotEmpty) {
      score += 10;
    } else {
      tips.add('Add your phone number.');
    }

    if (input.targetRole.trim().isNotEmpty) {
      score += 10;
    } else {
      tips.add('Add a target role.');
    }

    if (_hasEducation(input)) {
      score += 15;
    } else {
      tips.add('Add your university and major.');
    }

    if (input.totalSkills >= 5 || _generatedSkillCount(cv) >= 5) {
      score += 15;
    } else {
      tips.add('Add at least 5 technical skills, tools, or soft skills.');
    }

    if (input.projects.isNotEmpty || cv.projects.isNotEmpty) {
      score += 15;
    } else {
      tips.add('Add at least one project.');
    }

    if (input.achievements.isNotEmpty ||
        input.competitions.isNotEmpty ||
        input.completedSubjects.isNotEmpty ||
        cv.achievements.isNotEmpty ||
        cv.competitions.isNotEmpty ||
        cv.coursework.isNotEmpty) {
      score += 10;
    } else {
      tips.add(
        'Add achievements, competitions, or completed subjects from Masar.',
      );
    }

    if (_hasNoEmptyPlaceholderSections(cv)) {
      score += 5;
    } else {
      tips.add('Remove empty placeholder sections from the final CV.');
    }

    if (!input.links.any(
      (link) =>
          link.label.toLowerCase().contains('github') ||
          link.label.toLowerCase().contains('linkedin'),
    )) {
      tips.add('Add GitHub or LinkedIn link.');
    }

    return AtsScoreResult(score: score.clamp(0, 100), tips: tips);
  }

  bool _hasEducation(CvInput input) {
    return input.education.institution.trim().isNotEmpty &&
        (input.education.major.trim().isNotEmpty ||
            input.education.specialization.trim().isNotEmpty ||
            input.education.degree.trim().isNotEmpty);
  }

  int _generatedSkillCount(GeneratedCv cv) {
    return {
      ...cv.technicalSkills,
      ...cv.tools,
      ...cv.softSkills,
    }.where((item) => item.trim().isNotEmpty).length;
  }

  bool _hasNoEmptyPlaceholderSections(GeneratedCv cv) {
    const placeholders = [
      'no skills',
      'no projects',
      'not added',
      'major not',
      'no data',
    ];

    final text = [
      cv.summary,
      ...cv.technicalSkills,
      ...cv.tools,
      ...cv.softSkills,
      ...cv.coursework,
      ...cv.achievements,
      ...cv.competitions,
      ...cv.languages,
      ...cv.projects.expand(
        (project) => [
          project.title,
          project.description,
          ...project.descriptionBullets,
        ],
      ),
    ].join(' ').toLowerCase();

    return !placeholders.any(text.contains);
  }
}
