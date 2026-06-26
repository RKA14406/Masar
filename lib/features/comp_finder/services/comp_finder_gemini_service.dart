import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/gemini_quiz_config.dart';
import '../models/competition_model.dart';

class CompFinderGeminiService {
  const CompFinderGeminiService();

  /// Calls Gemini backend to fill fit_score, fit_reason, missing_skills,
  /// recommended_preparation for competitions that don't have them yet.
  Future<List<Competition>> enrichWithAI({
    required List<Competition> competitions,
    required String college,
    required String specialization,
    required List<String> completedSubjects,
    required String username,
    int age = 0,
  }) async {
    if (competitions.isEmpty) return competitions;

    // Only send competitions that have no AI data yet
    final toEnrich = competitions
        .where((c) => c.fitReason.isEmpty)
        .take(12)
        .toList();
    if (toEnrich.isEmpty) return competitions;

    final prompt = _buildPrompt(
      competitions: toEnrich,
      college: college,
      specialization: specialization,
      completedSubjects: completedSubjects,
      username: username,
      age: age,
    );

    try {
      final response = await http
          .post(
            Uri.parse(GeminiQuizConfig.backendUrl),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'prompt': prompt}),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return competitions;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) return competitions;

      final data = body['data'];
      if (data == null) return competitions;

      final rawList =
          (data as Map<String, dynamic>)['competitions'] as List<dynamic>? ??
          [];

      final aiMap = <String, Map<String, dynamic>>{};
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          final id = item['id']?.toString();
          if (id != null && id.isNotEmpty) aiMap[id] = item;
        }
      }

      if (aiMap.isEmpty) return competitions;

      return competitions.map((c) {
        final ai = aiMap[c.id];
        if (ai == null) return c;
        return c.copyWith(
          fitScore: (ai['fit_score'] as num?)?.toDouble() ?? 0.0,
          fitReason: (ai['fit_reason'] ?? '').toString().trim(),
          missingSkills: List<String>.from(ai['missing_skills'] ?? []),
          recommendedPreparation: (ai['recommended_preparation'] ?? '')
              .toString()
              .trim(),
        );
      }).toList();
    } catch (_) {
      return competitions;
    }
  }

  String _buildPrompt({
    required List<Competition> competitions,
    required String college,
    required String specialization,
    required List<String> completedSubjects,
    required String username,
    required int age,
  }) {
    final compsJson = jsonEncode(
      competitions
          .map(
            (c) => {
              'id': c.id,
              'title': c.title,
              'field': c.field,
              'difficulty_level': c.difficultyLevel,
              'skill_tags': c.skillTags,
              'major_tags': c.majorTags,
              'organizer': c.organizer,
            },
          )
          .toList(),
    );

    return '''
You are the competition match analyzer for Vision Career — a career guidance platform for university students.

User profile:
- Name: ${username.isEmpty ? 'Student' : username}
- Age: ${age > 0 ? '$age' : 'unspecified'}
- College: ${college.isEmpty ? 'unspecified' : college}
- Specialization: ${specialization.isEmpty ? 'unspecified' : specialization}
- Completed subjects: ${completedSubjects.isEmpty ? 'none yet' : completedSubjects.join(', ')}

Task:
Analyze EVERY competition in the list below and return how well it matches this specific user.

Rules:
- fit_score: number from 0.0 (no match) to 1.0 (perfect match), based on the user's college/specialization/subjects vs the competition's field and skill_tags
- fit_reason: exactly 1-2 sentences. Be specific about WHY this user's background fits this competition. Mention the specialization or subjects if relevant.
- missing_skills: exactly 2-4 skills the user would gain or develop by participating
- recommended_preparation: one short, actionable sentence on how to best prepare
- Include ALL ${competitions.length} competitions from the input — same count, same ids

Return ONLY valid JSON, no explanation text, no markdown:
{
  "competitions": [
    {
      "id": "exact_id_from_input",
      "fit_score": 0.85,
      "fit_reason": "string",
      "missing_skills": ["skill1", "skill2", "skill3"],
      "recommended_preparation": "string"
    }
  ]
}

Competitions to analyze:
$compsJson
''';
  }
}
