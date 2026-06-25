import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/gemini_quiz_config.dart';
import 'phase0_mapping_service.dart';

class Phase0JobSalarySnapshot {
  final String jordan;
  final String gulf;
  final String worldwide;

  const Phase0JobSalarySnapshot({
    required this.jordan,
    required this.gulf,
    required this.worldwide,
  });

  factory Phase0JobSalarySnapshot.fromJson(Map<String, dynamic> json) {
    return Phase0JobSalarySnapshot(
      jordan: (json['jordan'] ?? '').toString().trim(),
      gulf: (json['gulf'] ?? '').toString().trim(),
      worldwide: (json['worldwide'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jordan': jordan,
      'gulf': gulf,
      'worldwide': worldwide,
    };
  }

  bool get hasAnyValue =>
      jordan.isNotEmpty || gulf.isNotEmpty || worldwide.isNotEmpty;
}

class Phase0JobInsight {
  final String title;
  final Phase0JobSalarySnapshot averageSalary;

  const Phase0JobInsight({
    required this.title,
    required this.averageSalary,
  });

  factory Phase0JobInsight.fromJson(Map<String, dynamic> json) {
    return Phase0JobInsight(
      title: (json['job_title'] ?? '').toString().trim(),
      averageSalary: Phase0JobSalarySnapshot.fromJson(
        Map<String, dynamic>.from(
          json['average_salary'] as Map<String, dynamic>? ?? const {},
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_title': title,
      'average_salary': averageSalary.toJson(),
    };
  }

  bool get isValid => title.isNotEmpty && averageSalary.hasAnyValue;
}

class Phase0SpecialtyRecommendation {
  final String specialtyKey;
  final String title;
  final String shortDescription;
  final String fitReason;
  final double confidence;
  final List<Phase0JobInsight> jobs;

  const Phase0SpecialtyRecommendation({
    required this.specialtyKey,
    required this.title,
    required this.shortDescription,
    required this.fitReason,
    required this.confidence,
    this.jobs = const [],
  });

  factory Phase0SpecialtyRecommendation.fromJson(Map<String, dynamic> json) {
    final rawJobs = json['jobs'] as List<dynamic>? ?? const [];

    return Phase0SpecialtyRecommendation(
      specialtyKey: (json['specialty_key'] ?? '').toString().trim(),
      title: (json['title'] ?? '').toString().trim(),
      shortDescription: (json['short_description'] ?? '').toString().trim(),
      fitReason: (json['fit_reason'] ?? '').toString().trim(),
      confidence: _parseConfidence(json['confidence']),
      jobs: rawJobs
          .whereType<Map<String, dynamic>>()
          .map(Phase0JobInsight.fromJson)
          .where((item) => item.isValid)
          .take(5)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'specialty_key': specialtyKey,
      'title': title,
      'short_description': shortDescription,
      'fit_reason': fitReason,
      'confidence': confidence,
      'jobs': jobs.map((item) => item.toJson()).toList(growable: false),
    };
  }

  static double _parseConfidence(dynamic value) {
    if (value is num) {
      return value.toDouble().clamp(0.0, 1.0);
    }
    return (double.tryParse(value.toString()) ?? 0.0).clamp(0.0, 1.0);
  }
}

class Phase0GeminiService {
  const Phase0GeminiService();

  Future<List<Phase0SpecialtyRecommendation>> recommendFromFreeText({
    required String userDescription,
    required List<Phase0SpecialtyOption> allowedSpecialties,
    String language = 'English',
  }) {
    return recommendFromDescription(
      userDescription: userDescription,
      allowedSpecialties: allowedSpecialties,
      language: language,
    );
  }

  Future<List<Phase0SpecialtyRecommendation>> recommendFromDescription({
    required String userDescription,
    required List<Phase0SpecialtyOption> allowedSpecialties,
    String language = 'English',
  }) async {
    final prompt = _buildDescriptionPrompt(
      userDescription: userDescription,
      allowedSpecialties: allowedSpecialties,
      responseLanguage: _normalizeResponseLanguage(language),
    );

    final decoded = await _requestJson(prompt);

    return _extractRecommendations(
      decoded,
      allowedSpecialties,
      minCount: 1,
      maxCount: 5,
    );
  }

  Future<List<String>> buildGuidedChatQuestions({
    required Map<String, dynamic> interestProfile,
    required List<Phase0SpecialtyOption> allowedSpecialties,
    String language = 'English',
  }) async {
    final prompt = _buildGuidedChatQuestionsPrompt(
      interestProfile: interestProfile,
      allowedSpecialties: allowedSpecialties,
      responseLanguage: _normalizeResponseLanguage(language),
    );

    final decoded = await _requestJson(prompt);

    final rawQuestions = decoded['questions'] as List<dynamic>? ?? const [];

    final questions = rawQuestions
        .map((q) => q.toString().trim())
        .where((q) => q.isNotEmpty)
        .take(6)
        .toList(growable: false);

    if (questions.length < 4) {
      throw const FormatException(
        'Phase 0 guided chat must return 4 to 6 usable questions.',
      );
    }

    return questions;
  }

  Future<String> summarizeDiscoveryChat({
    required List<Map<String, dynamic>> transcript,
    String language = 'English',
  }) async {
    final prompt = _buildChatSummaryPrompt(
      transcript: transcript,
      responseLanguage: _normalizeResponseLanguage(language),
    );

    final decoded = await _requestJson(prompt);

    final summary = (decoded['summary'] ?? '').toString().trim();

    if (summary.isEmpty) {
      throw const FormatException('Phase 0 chat summary was empty.');
    }

    return summary;
  }

  Future<List<Phase0SpecialtyRecommendation>> recommendFromDiscoveryPackage({
    required Map<String, dynamic> interestProfile,
    required String chatSummary,
    required Map<String, dynamic> aptitudeSummary,
    required List<Phase0SpecialtyOption> allowedSpecialties,
    String language = 'English',
  }) async {
    final prompt = _buildDiscoveryPackagePrompt(
      interestProfile: interestProfile,
      chatSummary: chatSummary,
      aptitudeSummary: aptitudeSummary,
      allowedSpecialties: allowedSpecialties,
      responseLanguage: _normalizeResponseLanguage(language),
    );

    final decoded = await _requestJson(prompt);

    return _extractRecommendations(
      decoded,
      allowedSpecialties,
      minCount: 1,
      maxCount: 5,
    );
  }

  Future<Map<String, dynamic>> _requestJson(String prompt) async {
    final response = await http.post(
      Uri.parse(GeminiQuizConfig.backendUrl),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': prompt}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Backend request failed (${response.statusCode}): ${response.body}',
      );
    }

    final body = jsonDecode(response.body);

    if (body['success'] != true) {
      throw Exception('AI failed: ${body['error']}');
    }

    final data = body['data'];

    if (data == null) {
      throw const FormatException('Backend returned empty data.');
    }

    debugPrint('AI RAW RESPONSE: $data');

    return Map<String, dynamic>.from(data);
  }

  List<Phase0SpecialtyRecommendation> _extractRecommendations(
      Map<String, dynamic> decoded,
      List<Phase0SpecialtyOption> allowedSpecialties, {
        required int minCount,
        required int maxCount,
      }) {
    final allowedKeys = allowedSpecialties
        .map((e) => e.specialtyKey.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();

    final rawItems =
        decoded['suggested_specialties'] as List<dynamic>? ?? const [];

    final recommendations = rawItems
        .whereType<Map<String, dynamic>>()
        .map(Phase0SpecialtyRecommendation.fromJson)
        .where(
          (item) =>
      item.specialtyKey.isNotEmpty &&
          allowedKeys.contains(item.specialtyKey.toLowerCase()) &&
          item.title.isNotEmpty &&
          item.shortDescription.isNotEmpty &&
          item.fitReason.isNotEmpty,
    )
        .take(maxCount)
        .toList(growable: false);

    if (recommendations.length < minCount) {
      throw const FormatException(
        'Phase 0 Gemini returned no valid specialties after validation.',
      );
    }

    return recommendations;
  }

  String _buildDescriptionPrompt({
    required String userDescription,
    required List<Phase0SpecialtyOption> allowedSpecialties,
    required String responseLanguage,
  }) {
    return '''
You are the specialty recommendation layer for Vision Career.

Task:
Read the user's description and recommend 3 to 5 specialties.
You may ONLY use specialties from the allowed list below.
Do NOT invent colleges.
Do NOT invent specialties.
Do NOT generate subjects, nodes, or courses.
Do NOT control navigation.
Keep the SAME OLD specialty recommendation logic, but enrich each specialty with career outlook.
For each recommended specialty, also return exactly 5 jobs the student can work in after joining that major.
For every returned job, also return average salary estimates in this exact order of markets:
1) Jordan
2) Gulf countries
3) Worldwide
Salary estimates may be approximate, but they must be realistic, concise, and useful.
Write all user-facing text fields in $responseLanguage.
Never translate or alter specialty_key values.

User description:
$userDescription

Allowed specialties:
${jsonEncode(allowedSpecialties.map((e) => e.toJson()).toList())}

Return ONLY valid JSON in this exact shape:
{
  "suggested_specialties": [
    {
      "specialty_key": "string",
      "title": "string",
      "short_description": "string",
      "fit_reason": "string",
      "confidence": 0.0,
      "jobs": [
        {
          "job_title": "string",
          "average_salary": {
            "jordan": "string",
            "gulf": "string",
            "worldwide": "string"
          }
        }
      ]
    }
  ]
}
''';
  }

  String _buildGuidedChatQuestionsPrompt({
    required Map<String, dynamic> interestProfile,
    required List<Phase0SpecialtyOption> allowedSpecialties,
    required String responseLanguage,
  }) {
    return '''
You are creating a short guided discovery chat for Vision Career.

Task:
Generate exactly 5 short, focused questions.
This is NOT an open chatbot.
The questions should help clarify:
- motivation
- favorite school subjects
- practical vs technical preference
- creative vs logic preference
- preferred type of future work
Write every question in $responseLanguage.

Use the user's interest profile for context, but do not mention specialties directly.

Interest profile:
${jsonEncode(interestProfile)}

Allowed specialties context:
${jsonEncode(allowedSpecialties.map((e) => e.toJson()).toList())}

Return ONLY valid JSON in this exact shape:
{
  "questions": [
    "question 1",
    "question 2",
    "question 3",
    "question 4",
    "question 5"
  ]
}
''';
  }

  String _buildChatSummaryPrompt({
    required List<Map<String, dynamic>> transcript,
    required String responseLanguage,
  }) {
    return '''
You are summarizing a short guided discovery chat for Vision Career.

Task:
Write one concise summary paragraph capturing:
- what the user seems interested in
- what kind of work style they prefer
- what subjects or strengths they mentioned
- any strong fit signals
Write the summary in $responseLanguage.

Transcript:
${jsonEncode(transcript)}

Return ONLY valid JSON in this exact shape:
{
  "summary": "string"
}
''';
  }

  String _buildDiscoveryPackagePrompt({
    required Map<String, dynamic> interestProfile,
    required String chatSummary,
    required Map<String, dynamic> aptitudeSummary,
    required List<Phase0SpecialtyOption> allowedSpecialties,
    required String responseLanguage,
  }) {
    return '''
You are the specialty recommendation layer for Vision Career.

Task:
Recommend 3 to 5 specialties based on the user's full discovery package.
You may ONLY use specialties from the allowed list below.
Do NOT invent colleges.
Do NOT invent specialties.
Do NOT generate subjects, nodes, or courses.
Keep the SAME OLD specialty recommendation logic, but enrich each specialty with career outlook.
For each recommended specialty, also return exactly 5 jobs the student can work in after joining that major.
For every returned job, also return average salary estimates in this exact order of markets:
1) Jordan
2) Gulf countries
3) Worldwide
Salary estimates may be approximate, but they must be realistic, concise, and useful.
Write all user-facing text fields in $responseLanguage.
Never translate or alter specialty_key values.

Interest profile:
${jsonEncode(interestProfile)}

Chat summary:
$chatSummary

Aptitude summary:
${jsonEncode(aptitudeSummary)}

Allowed specialties:
${jsonEncode(allowedSpecialties.map((e) => e.toJson()).toList())}

Return ONLY valid JSON in this exact shape:
{
  "suggested_specialties": [
    {
      "specialty_key": "string",
      "title": "string",
      "short_description": "string",
      "fit_reason": "string",
      "confidence": 0.0,
      "jobs": [
        {
          "job_title": "string",
          "average_salary": {
            "jordan": "string",
            "gulf": "string",
            "worldwide": "string"
          }
        }
      ]
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