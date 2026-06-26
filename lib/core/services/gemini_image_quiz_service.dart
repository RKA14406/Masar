import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

import '../../data/models/image_quiz_models.dart';
import '../../data/models/subject_model.dart';
import '../constants/gemini_quiz_config.dart';

class GeminiImageQuizService {
  const GeminiImageQuizService();

  Future<ImageQuizEvaluation> evaluateImageSubmission({
    required Subject subject,
    required String college,
    required String specialization,
    required String achievementsSummary,
    required String instructions,
    required String imageTask,
    required List<String> rubric,
    required int passingScore,
    required File imageFile,
    String language = 'English',
  }) async {
    final bytes = await imageFile.readAsBytes();
    if (bytes.isEmpty) {
      throw const FormatException('Selected image file is empty.');
    }

    final mimeType = lookupMimeType(imageFile.path, headerBytes: bytes) ?? 'image/jpeg';
    if (!mimeType.startsWith('image/')) {
      throw FormatException('Unsupported file type for image quiz: $mimeType');
    }

    final prompt = _buildEvaluationPrompt(
      subject: subject,
      college: college,
      specialization: specialization,
      achievementsSummary: achievementsSummary,
      instructions: instructions,
      imageTask: imageTask,
      rubric: rubric,
      passingScore: passingScore,
      responseLanguage: _normalizeResponseLanguage(language),
    );

    final response = await http.post(
      Uri.parse(GeminiQuizConfig.backendUrl),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': prompt,
        'image': base64Encode(bytes),
        'mimeType': mimeType,
      }),
    );

    if (response.statusCode != 200) {
      throw HttpException(
        'Image grading backend request failed (${response.statusCode}): ${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (body['success'] != true) {
      throw Exception('AI failed: ${body['error']}');
    }

    final data = body['data'];
    if (data == null) {
      throw const FormatException('Image grading backend returned empty data.');
    }

    final decoded = Map<String, dynamic>.from(data as Map);
    print("AI RESPONSE: $decoded");

    final evaluation = ImageQuizEvaluation.fromJson(decoded);

    if (evaluation.feedback.isEmpty) {
      throw const FormatException('Gemini image grading returned invalid feedback.');
    }

    return evaluation;
  }

  String _buildEvaluationPrompt({
    required Subject subject,
    required String college,
    required String specialization,
    required String achievementsSummary,
    required String instructions,
    required String imageTask,
    required List<String> rubric,
    required int passingScore,
    required String responseLanguage,
  }) {
    final safeRubric = rubric.where((e) => e.trim().isNotEmpty).toList(growable: false);

    return '''
You are the image-submission evaluator for Masar.

You are grading a student's uploaded image for a subject completion quiz.

STRICT RULES:
- Return ONLY valid JSON
- No markdown
- No code fences
- No extra commentary
- Score from 0 to 100 only
- Be strict but fair
- Fail blank, unreadable, irrelevant, or low-effort submissions
- Check whether the image actually matches the requested task
- Write all user-facing feedback fields in $responseLanguage
- Keep JSON keys exactly as specified in English

Subject context:
- College: $college
- Specialization: $specialization
- Subject code: ${subject.code}
- Subject name: ${subject.name}
- Subject description: ${subject.description}
- Subject skills: ${subject.skills.join(', ')}
- Achievements summary: $achievementsSummary

Quiz instructions:
$instructions

Image task:
$imageTask

Rubric:
${jsonEncode(safeRubric)}

Passing score:
$passingScore

Evaluate the uploaded image and return ONLY this JSON shape:
{
  "passed": true,
  "score_percent": 76,
  "feedback": "short evaluator feedback",
  "strengths": ["item", "item"],
  "issues": ["item", "item"],
  "rubric_checks": ["item", "item"]
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
