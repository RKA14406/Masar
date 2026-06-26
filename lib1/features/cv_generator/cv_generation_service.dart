import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/gemini_quiz_config.dart';
import 'cv_model.dart';

class CvGenerationService {
  const CvGenerationService();

  static const Duration _requestTimeout = Duration(seconds: 8);

  Future<GeneratedCv> generateWithGemini(CvInput input) async {
    final response = await http
        .post(
          Uri.parse(GeminiQuizConfig.backendUrl),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'prompt': _buildPrompt(input)}),
        )
        .timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw Exception('CV generation failed (${response.statusCode}).');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['success'] != true) {
      throw Exception((body['error'] ?? 'CV generation failed').toString());
    }

    final data = body['data'];
    if (data is! Map) {
      throw const FormatException('CV generation returned invalid JSON.');
    }

    return _sanitize(
      input,
      GeneratedCv.fromJson(Map<String, dynamic>.from(data), input),
    );
  }

  GeneratedCv generateFallback(CvInput input) {
    final summary = input.targetRole.trim().isEmpty
        ? '${_name(input)} is a student building academic and practical skills through Masar.'
        : '${_name(input)} is a student preparing for ${input.targetRole.trim()} roles, with academic progress and project work reflected in this CV.';

    return GeneratedCv(
      input: input,
      summary: summary,
      education: [input.education].where(_validEducation).toList(),
      technicalSkills: input.technicalSkills,
      softSkills: input.softSkills,
      tools: input.tools,
      projects: input.projects
          .map(
            (project) => CvProject(
              title: project.title,
              descriptionBullets: project.description.trim().isEmpty
                  ? const []
                  : [project.description.trim()],
              technologies: project.technologies,
              link: project.link,
            ),
          )
          .toList(),
      coursework: input.completedSubjects,
      achievements: input.achievements,
      competitions: input.competitions,
      experience: input.experience,
      languages: input.languages,
    );
  }

  GeneratedCv _sanitize(CvInput input, GeneratedCv generated) {
    final inputProjectsByTitle = {
      for (final project in input.projects)
        project.title.trim().toLowerCase(): project,
    };

    final safeProjects = generated.projects
        .where(
          (project) => inputProjectsByTitle.containsKey(
            project.title.trim().toLowerCase(),
          ),
        )
        .map((project) {
          final source =
              inputProjectsByTitle[project.title.trim().toLowerCase()]!;
          final bullets = project.descriptionBullets.isNotEmpty
              ? project.descriptionBullets
              : source.description.trim().isEmpty
              ? <String>[]
              : [source.description.trim()];
          return CvProject(
            title: source.title,
            descriptionBullets: bullets,
            technologies: source.technologies,
            link: source.link,
          );
        })
        .toList();

    return GeneratedCv(
      input: input,
      summary: generated.summary.trim().isNotEmpty
          ? generated.summary.trim()
          : generateFallback(input).summary,
      education: [input.education].where(_validEducation).toList(),
      technicalSkills: _allowed(
        generated.technicalSkills,
        input.technicalSkills,
      ),
      softSkills: _allowed(generated.softSkills, input.softSkills),
      tools: _allowed(generated.tools, input.tools),
      projects: safeProjects.isNotEmpty
          ? safeProjects
          : generateFallback(input).projects,
      coursework: input.completedSubjects,
      achievements: input.achievements,
      competitions: input.competitions,
      experience: input.experience,
      languages: input.languages,
    );
  }

  List<String> _allowed(List<String> generated, List<String> source) {
    final sourceByKey = {
      for (final item in source) item.trim().toLowerCase(): item.trim(),
    };
    final safe = generated
        .map((item) => sourceByKey[item.trim().toLowerCase()])
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toSet()
        .toList();
    return safe.isNotEmpty ? safe : source;
  }

  bool _validEducation(CvEducation education) {
    return education.institution.trim().isNotEmpty ||
        education.degree.trim().isNotEmpty ||
        education.major.trim().isNotEmpty ||
        education.specialization.trim().isNotEmpty;
  }

  String _name(CvInput input) =>
      input.fullName.trim().isEmpty ? 'This student' : input.fullName.trim();

  String _buildPrompt(CvInput input) {
    return '''
You are creating an ATS-friendly student CV for Masar.

Rules:
Use only the provided user data.
Do not invent experience, certificates, companies, awards, projects, grades, scores, links, or skills.
If a section has no data, omit it.
Return valid JSON only.
Write in a professional student CV style.
Keep the CV ATS-friendly.
Avoid exaggerated claims.
Avoid words like expert, certified, award-winning, senior, unless explicitly provided.
Do not create visual layout. Only return structured CV content.

User data:
${jsonEncode(input.toJson())}

Return ONLY valid JSON in this exact shape:
{
  "header": {
    "name": "string",
    "email": "string",
    "phone": "string",
    "location": "string",
    "links": [
      {"label": "string", "url": "string"}
    ]
  },
  "targetRole": "string",
  "summary": "string",
  "education": [
    {
      "institution": "string",
      "degree": "string",
      "major": "string",
      "graduationYear": "string",
      "details": ["string"]
    }
  ],
  "skills": {
    "technical": ["string"],
    "tools": ["string"],
    "soft": ["string"]
  },
  "projects": [
    {
      "title": "string",
      "descriptionBullets": ["string"],
      "technologies": ["string"],
      "link": "string"
    }
  ],
  "coursework": ["string"],
  "achievements": ["string"],
  "competitions": ["string"],
  "experience": [
    {
      "title": "string",
      "organization": "string",
      "date": "string",
      "bullets": ["string"]
    }
  ],
  "languages": ["string"]
}
''';
  }
}
