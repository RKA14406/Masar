import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../data/models/subject_model.dart';
import '../constants/gemini_quiz_config.dart';

class CareerJobSuggestion {
  final String title;
  final String shortDescription;
  final String fitReason;
  final String fullDescription;

  const CareerJobSuggestion({
    required this.title,
    required this.shortDescription,
    required this.fitReason,
    required this.fullDescription,
  });

  factory CareerJobSuggestion.fromJson(Map<String, dynamic> json) {
    return CareerJobSuggestion(
      title: (json['title'] ?? '').toString().trim(),
      shortDescription: (json['short_description'] ?? '').toString().trim(),
      fitReason: (json['fit_reason'] ?? '').toString().trim(),
      fullDescription: (json['full_description'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'short_description': shortDescription,
      'fit_reason': fitReason,
      'full_description': fullDescription,
    };
  }
}

class CareerTopic {
  final String title;
  final String description;
  final List<String> skillsGained;
  final List<String> relatedJobs;

  const CareerTopic({
    required this.title,
    required this.description,
    required this.skillsGained,
    required this.relatedJobs,
  });

  factory CareerTopic.fromJson(Map<String, dynamic> json) {
    return CareerTopic(
      title: (json['title'] ?? '').toString().trim(),
      description: (json['description'] ?? '').toString().trim(),
      skillsGained: (json['skills_gained'] as List<dynamic>? ?? const [])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(),
      relatedJobs: (json['related_jobs'] as List<dynamic>? ?? const [])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'skills_gained': skillsGained,
      'related_jobs': relatedJobs,
    };
  }
}

class CareerLlmService {
  Future<List<CareerJobSuggestion>> suggestJobs({
    required String college,
    required String specialization,
    required List<Subject> completedSubjects,
    String language = 'English',
  }) async {
    final prompt = _buildJobSuggestionPrompt(
      college: college,
      specialization: specialization,
      completedSubjects: completedSubjects,
      responseLanguage: _normalizeResponseLanguage(language),
    );

    final decoded = await _requestJson(prompt);
    final rawJobs = decoded['jobs'] as List<dynamic>? ?? const [];

    final jobs = rawJobs
        .map((item) => CareerJobSuggestion.fromJson(item as Map<String, dynamic>))
        .where((job) =>
            job.title.isNotEmpty &&
            job.shortDescription.isNotEmpty &&
            job.fitReason.isNotEmpty)
        .take(20)
        .toList();

    if (jobs.length < 8) {
      throw const FormatException(
        'Career job suggestion response is too short. Expected a strong list of jobs.',
      );
    }

    return jobs;
  }

  Future<List<CareerTopic>> generatePhase3Topics({
    required String college,
    required String specialization,
    required List<Subject> completedSubjects,
    required List<CareerJobSuggestion> selectedJobs,
    String language = 'English',
  }) async {
    final prompt = _buildPhase3TopicsPrompt(
      college: college,
      specialization: specialization,
      completedSubjects: completedSubjects,
      selectedJobs: selectedJobs,
      responseLanguage: _normalizeResponseLanguage(language),
    );

    final decoded = await _requestJson(prompt);
    final rawTopics = decoded['topics'] as List<dynamic>? ?? const [];

    final topics = rawTopics
        .map((item) => CareerTopic.fromJson(item as Map<String, dynamic>))
        .where((topic) =>
            topic.title.isNotEmpty &&
            topic.description.isNotEmpty &&
            topic.skillsGained.isNotEmpty)
        .take(5)
        .toList();

    if (topics.length < 3) {
      throw const FormatException(
        'Phase 3 generation must return 3 to 5 usable learning topics.',
      );
    }

    return topics;
  }

  Future<Map<String, dynamic>> _requestJson(String prompt) async {
    final response = await http.post(
      Uri.parse(GeminiQuizConfig.backendUrl),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': prompt}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Career LLM backend request failed (${response.statusCode}): ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (body['success'] != true) {
      throw Exception('AI failed: ${body['error']}');
    }

    final data = body['data'];

    if (data == null) {
      throw const FormatException('Career LLM backend returned empty data.');
    }

    return Map<String, dynamic>.from(data as Map);
  }

  String _buildJobSuggestionPrompt({
    required String college,
    required String specialization,
    required List<Subject> completedSubjects,
    required String responseLanguage,
  }) {
    final subjectLines = completedSubjects
        .map((subject) => '- ${subject.code} | ${subject.name} | skills: ${subject.skills.join(', ')}')
        .join('\n');

    return '''
You are helping a university student choose realistic career directions.

Context:
- College: $college
- Specialization: $specialization
- Completed subjects:
$subjectLines

Task:
Suggest 10 to 20 realistic entry-level or early-career job roles that fit this academic background.
The jobs must be relevant to the specialization and should feel useful for a student building toward employability.
Keep the language clear and practical.
Do not suggest senior-only jobs.
Write all user-facing text fields in $responseLanguage.
Keep JSON keys exactly as specified in English.

Return ONLY valid JSON in this exact shape:
{
  "jobs": [
    {
      "title": "string",
      "short_description": "string",
      "fit_reason": "string",
      "full_description": "string"
    }
  ]
}
''';
  }

  String _buildPhase3TopicsPrompt({
    required String college,
    required String specialization,
    required List<Subject> completedSubjects,
    required List<CareerJobSuggestion> selectedJobs,
    required String responseLanguage,
  }) {
    final subjectLines = completedSubjects
        .map((subject) => '- ${subject.code} | ${subject.name} | skills: ${subject.skills.join(', ')}')
        .join('\n');

    final selectedJobLines = selectedJobs
        .map((job) => '- ${job.title}: ${job.shortDescription}')
        .join('\n');

    return '''
You are generating the final employability phase for a university learning-path application.

Context:
- College: $college
- Specialization: $specialization
- User selected jobs:
$selectedJobLines
- Completed academic subjects:
$subjectLines

Task:
Generate exactly 3 to 5 FINAL PHASE learning topics.
These must be TOPICS, not course names, not platform names, and not certifications.
They should bridge the gap between university study and job readiness.
Each topic must feel practical and portfolio-relevant.
Each topic must include:
- title
- description
- skills_gained (3 to 6 items)
- related_jobs (one or more from the selected jobs)
Write all user-facing text fields in $responseLanguage.
Keep JSON keys exactly as specified in English.

Return ONLY valid JSON in this exact shape:
{
  "topics": [
    {
      "title": "string",
      "description": "string",
      "skills_gained": ["string"],
      "related_jobs": ["string"]
    }
  ]
}
''';
  }

  String _normalizeResponseLanguage(String language) {
    final normalized = language.trim().toLowerCase();
    if (normalized == 'ar' ||
        normalized == 'arabic' ||
        normalized == 'العربية') {
      return 'Arabic';
    }
    return 'English';
  }
}
