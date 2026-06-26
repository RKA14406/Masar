import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/gemini_quiz_config.dart';
import 'portfolio_model.dart';

class PortfolioGenerationService {
  const PortfolioGenerationService();

  Future<GeneratedPortfolio> generateWithGemini({
    required PortfolioInput input,
    String language = 'English',
  }) async {
    final response = await http.post(
      Uri.parse(GeminiQuizConfig.backendUrl),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': _buildPrompt(input, language)}),
    );

    if (response.statusCode != 200) {
      throw Exception('Portfolio generation failed (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception(
        (body['error'] ?? 'Portfolio generation failed').toString(),
      );
    }

    final data = body['data'];
    if (data is! Map) {
      throw const FormatException(
        'Portfolio generation returned invalid JSON.',
      );
    }

    final generated = GeneratedPortfolio.fromJson(
      Map<String, dynamic>.from(data),
    );

    return _sanitizeGenerated(input, generated);
  }

  GeneratedPortfolio generateFallback(PortfolioInput input) {
    return _sanitizeGenerated(
      input,
      GeneratedPortfolio(
        headline: _fallbackHeadline(input),
        summary: _fallbackSummary(input),
        skills: input.skills,
        projects: input.projects,
        academicProgress: _fallbackAcademicProgress(input),
        achievements: input.achievements,
        competitions: input.competitions,
        links: input.links,
      ),
    );
  }

  String _buildPrompt(PortfolioInput input, String language) {
    return '''
You are helping a university student create a truthful portfolio draft for Masar.

Rules:
Use only the provided information.
Do not invent projects, certificates, competitions, grades, companies, awards, or skills.
Do not call the student an expert, certified, professional engineer, or award-winning unless that exact fact is provided.
If a section has no data, write a short neutral placeholder or omit the section.
Keep wording polished, concise, and student-appropriate.
Write all user-facing text in $language.
Return valid JSON only.

Provided student data:
${jsonEncode(input.toJson())}

Return ONLY valid JSON in this exact shape:
{
  "headline": "string",
  "summary": "string",
  "skills": ["string"],
  "projects": [
    {
      "title": "string",
      "description": "string",
      "technologies": ["string"],
      "link": "string"
    }
  ],
  "academicProgress": "string",
  "achievements": ["string"],
  "competitions": ["string"],
  "links": [
    {
      "label": "string",
      "url": "string"
    }
  ]
}
''';
  }

  GeneratedPortfolio _sanitizeGenerated(
    PortfolioInput input,
    GeneratedPortfolio generated,
  ) {
    final inputSkillLookup = {
      for (final skill in input.skills)
        skill.trim().toLowerCase(): skill.trim(),
    };

    final safeSkills = generated.skills
        .map((skill) => inputSkillLookup[skill.trim().toLowerCase()])
        .whereType<String>()
        .where((skill) => skill.isNotEmpty)
        .toSet()
        .toList(growable: false);

    final generatedProjectsByTitle = {
      for (final project in generated.projects)
        project.title.trim().toLowerCase(): project,
    };

    final safeProjects = input.projects
        .map((project) {
          final polished =
              generatedProjectsByTitle[project.title.trim().toLowerCase()];
          return PortfolioProjectInput(
            title: project.title,
            description: (polished?.description.isNotEmpty ?? false)
                ? polished!.description
                : project.description,
            technologies: project.technologies,
            link: project.link,
          );
        })
        .toList(growable: false);

    return GeneratedPortfolio(
      headline: generated.headline.isNotEmpty
          ? generated.headline
          : _fallbackHeadline(input),
      summary: generated.summary.isNotEmpty
          ? generated.summary
          : _fallbackSummary(input),
      skills: safeSkills.isNotEmpty ? safeSkills : input.skills,
      projects: safeProjects,
      academicProgress: generated.academicProgress.isNotEmpty
          ? generated.academicProgress
          : _fallbackAcademicProgress(input),
      achievements: input.achievements,
      competitions: input.competitions,
      links: input.links,
    );
  }

  String _fallbackHeadline(PortfolioInput input) {
    if (input.goalTitle.isNotEmpty) return input.goalTitle;
    if (input.major.isNotEmpty) return '${input.major} Student';
    return 'Student Portfolio';
  }

  String _fallbackSummary(PortfolioInput input) {
    final name = input.fullName.isNotEmpty ? input.fullName : 'This student';
    final major = input.major.isNotEmpty ? ' studying ${input.major}' : '';
    final goal = input.goalTitle.isNotEmpty
        ? ' with an interest in ${input.goalTitle}'
        : '';
    final skills = input.skills.isNotEmpty
        ? ' Key skills include ${input.skills.take(5).join(', ')}.'
        : '';

    if (input.manualSummary.isNotEmpty) {
      return input.manualSummary;
    }

    return '$name is a university student$major$goal.$skills';
  }

  String _fallbackAcademicProgress(PortfolioInput input) {
    if (input.learningProgress.isNotEmpty) return input.learningProgress;
    if (input.completedSubjects.isEmpty) {
      return 'Learning progress can be added as subjects are completed.';
    }

    final subjects = input.completedSubjects.take(6).join(', ');
    return 'Completed Subjects: $subjects.';
  }
}
