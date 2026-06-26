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

    final fallback = competitions
        .map(
          (competition) => _withLocalFitAnalysis(
            competition: competition,
            college: college,
            specialization: specialization,
            completedSubjects: completedSubjects,
          ),
        )
        .toList();

    final toEnrich = fallback.take(20).toList();

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

      if (response.statusCode != 200) return fallback;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) return fallback;

      final data = body['data'];
      if (data == null) return fallback;

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

      if (aiMap.isEmpty) return fallback;

      return fallback.map((c) {
        final ai = aiMap[c.id];
        if (ai == null) return c;
        final fitScore = (ai['fit_score'] as num?)?.toDouble();
        final fitReason = (ai['fit_reason'] ?? '').toString().trim();
        final recommendedPreparation = (ai['recommended_preparation'] ?? '')
            .toString()
            .trim();
        return c.copyWith(
          fitScore: fitScore == null
              ? c.fitScore
              : fitScore.clamp(0.0, 1.0).toDouble(),
          fitReason: fitReason.isEmpty ? c.fitReason : fitReason,
          missingSkills: _stringList(ai['missing_skills']).isEmpty
              ? c.missingSkills
              : _stringList(ai['missing_skills']),
          recommendedPreparation: recommendedPreparation.isEmpty
              ? c.recommendedPreparation
              : recommendedPreparation,
        );
      }).toList();
    } catch (_) {
      return fallback;
    }
  }

  Competition _withLocalFitAnalysis({
    required Competition competition,
    required String college,
    required String specialization,
    required List<String> completedSubjects,
  }) {
    if (competition.fitReason.isNotEmpty && competition.fitScore > 0) {
      return competition;
    }

    final userTerms = <String>{
      ..._terms(college),
      ..._terms(specialization),
      ...completedSubjects.expand(_terms),
    };
    final compTerms = <String>{
      ..._terms(competition.field),
      ...competition.majorTags.expand(_terms),
      ...competition.skillTags.expand(_terms),
      ..._terms(competition.title),
    };

    final overlap = compTerms.where(userTerms.contains).toSet();
    final directMajorMatch = competition.majorTags.any(
      (tag) =>
          _normalizedContains(specialization, tag) ||
          _normalizedContains(tag, specialization) ||
          _normalizedContains(college, tag) ||
          _normalizedContains(tag, college),
    );
    final fieldMatch =
        _normalizedContains(specialization, competition.field) ||
        _normalizedContains(competition.field, specialization) ||
        _normalizedContains(college, competition.field) ||
        _normalizedContains(competition.field, college);

    var score = 0.34;
    if (college.trim().isNotEmpty || specialization.trim().isNotEmpty) {
      score += 0.08;
    }
    if (directMajorMatch) score += 0.24;
    if (fieldMatch) score += 0.18;
    score += (overlap.length * 0.045).clamp(0.0, 0.22);
    if (competition.difficultyLevel.toLowerCase() == 'beginner') score += 0.06;
    if (completedSubjects.isNotEmpty) score += 0.06;
    score = score.clamp(0.18, 0.96);

    final fitReason = _localFitReason(
      competition: competition,
      specialization: specialization,
      college: college,
      directMajorMatch: directMajorMatch,
      fieldMatch: fieldMatch,
      overlap: overlap,
    );

    return competition.copyWith(
      fitScore: score,
      fitReason: fitReason,
      missingSkills: _localSkillsToGain(competition, overlap),
      recommendedPreparation: _localPreparationTip(competition),
    );
  }

  String _localFitReason({
    required Competition competition,
    required String specialization,
    required String college,
    required bool directMajorMatch,
    required bool fieldMatch,
    required Set<String> overlap,
  }) {
    final path = specialization.trim().isNotEmpty
        ? specialization.trim()
        : college.trim().isNotEmpty
        ? college.trim()
        : 'your current Masar profile';

    if (directMajorMatch || fieldMatch) {
      return 'This competition fits $path because its ${competition.field} focus is close to your selected learning path.';
    }
    if (overlap.isNotEmpty) {
      final sample = overlap.take(2).join(', ');
      return 'This competition has a moderate fit with $path through shared skill areas like $sample.';
    }
    return 'This competition can broaden your experience beyond $path while still building useful student portfolio evidence.';
  }

  List<String> _localSkillsToGain(
    Competition competition,
    Set<String> overlap,
  ) {
    final skills = competition.skillTags
        .where((skill) => !overlap.contains(skill.trim().toLowerCase()))
        .take(4)
        .toList();
    if (skills.length >= 2) return skills;

    final fallback = [
      competition.field,
      'Problem solving',
      'Teamwork',
      'Project presentation',
    ].where((item) => item.trim().isNotEmpty).toList();
    return {...skills, ...fallback}.take(4).toList();
  }

  String _localPreparationTip(Competition competition) {
    final skills = competition.skillTags.take(2).join(', ');
    if (skills.isNotEmpty) {
      return 'Review $skills and prepare a short example project before applying.';
    }
    return 'Read the competition brief and prepare a concise project idea before applying.';
  }

  List<String> _stringList(dynamic value) {
    return (value as List<dynamic>? ?? const [])
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  Set<String> _terms(String value) {
    return value
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((term) => term.length > 2)
        .toSet();
  }

  bool _normalizedContains(String a, String b) {
    final left = a.trim().toLowerCase();
    final right = b.trim().toLowerCase();
    if (left.isEmpty || right.isEmpty) return false;
    return left.contains(right) || right.contains(left);
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
