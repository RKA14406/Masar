import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

import '../../core/constants/gemini_quiz_config.dart';
import 'general_quiz_model.dart';

class GeneralQuizService {
  static const int passPercent = 70;
  static const Duration _generationTimeout = Duration(seconds: 55);
  static const Duration _gradingTimeout = Duration(seconds: 55);

  Future<GeneralExam> generateExam({
    required String college,
    required String specialization,
    String language = 'English',
  }) async {
    final major = specialization.trim().isEmpty
        ? 'the selected major'
        : specialization.trim();

    try {
      final response = await http
          .post(
            Uri.parse(GeminiQuizConfig.backendUrl),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'prompt': _generationPrompt(
                college: college,
                major: major,
                language: language,
              ),
            }),
          )
          .timeout(_generationTimeout);

      if (response.statusCode != 200) {
        throw GeneralQuizServiceException(
          'Gemini exam generation failed (${response.statusCode}). Please try again.',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true || body['data'] == null) {
        throw const GeneralQuizServiceException(
          'Gemini did not return an exam. Please try again.',
        );
      }

      final exam = GeneralExam.fromJson(_asJsonMap(body['data']));
      if (exam.questions.length < 12) {
        throw const GeneralQuizServiceException(
          'Gemini returned too few questions. Please retry.',
        );
      }
      return _normalizeExam(exam);
    } on TimeoutException {
      throw const GeneralQuizServiceException(
        'Gemini is taking too long to create the exam. Please retry in a moment.',
      );
    } on GeneralQuizServiceException {
      rethrow;
    } catch (error) {
      throw GeneralQuizServiceException(
        'Could not create a Gemini exam: $error',
      );
    }
  }

  Future<GeneralExamEvaluation> gradeExam({
    required GeneralExam exam,
    required GeneralExamSubmission submission,
    required String college,
    required String specialization,
    String language = 'English',
  }) async {
    try {
      String? firstImagePath;
      for (final path in submission.imagePaths.values) {
        if (path.trim().isNotEmpty) {
          firstImagePath = path;
          break;
        }
      }
      final imagePayload = await _imagePayload(firstImagePath);

      final response = await http
          .post(
            Uri.parse(GeminiQuizConfig.backendUrl),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'prompt': _gradingPrompt(
                exam: exam,
                submission: submission,
                college: college,
                specialization: specialization,
                language: language,
              ),
              if (imagePayload != null) ...imagePayload,
            }),
          )
          .timeout(_gradingTimeout);

      if (response.statusCode != 200) {
        throw GeneralQuizServiceException(
          'Gemini grading failed (${response.statusCode}). Please try again.',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true || body['data'] == null) {
        throw const GeneralQuizServiceException(
          'Gemini did not return grading feedback. Please try again.',
        );
      }

      final evaluation = GeneralExamEvaluation.fromJson(_asJsonMap(body['data']));
      if (evaluation.feedback.isEmpty) {
        throw const GeneralQuizServiceException(
          'Gemini returned empty grading feedback. Please try again.',
        );
      }
      return evaluation;
    } on TimeoutException {
      throw const GeneralQuizServiceException(
        'Gemini is taking too long to grade this exam. Please retry.',
      );
    } on GeneralQuizServiceException {
      rethrow;
    } catch (error) {
      throw GeneralQuizServiceException('Could not grade the exam: $error');
    }
  }

  String _generationPrompt({
    required String college,
    required String major,
    required String language,
  }) {
    return '''
You are Masar's major-level exam creator.

Create a full, realistic university student readiness exam for this major.

Context:
- College: ${college.trim().isEmpty ? 'unspecified' : college}
- Major: $major
- Response language: $language

Exam requirements:
- The exam must feel serious and long enough for a major-level general quiz.
- Include 15 to 22 questions total.
- Include a mix of:
  - MCQ questions
  - written answer questions with text-area answers
  - at most ONE image/drawing/upload question ONLY if the major naturally needs diagrams, sketches, circuits, UI layouts, architecture drawings, flows, or visual design.
- Do not force image questions for majors where visual drawing is not useful.
- Never create more than one image question.
- Cover fundamentals, core major knowledge, problem solving, tools/technologies, and career readiness.
- Avoid fake claims or impossible tasks.
- Questions should assess whether the student is generally ready to unlock the final phase.
- Passing score must be 70.

Return ONLY valid JSON. No markdown. No extra text.

JSON shape:
{
  "title": "string",
  "instructions": "string",
  "passing_score": 70,
  "questions": [
    {
      "id": "q1",
      "section": "Fundamentals",
      "type": "mcq",
      "prompt": "string",
      "options": ["A", "B", "C", "D"],
      "expected_answer": "short correct answer or grading guide",
      "rubric": ["rubric item"],
      "points": 4
    },
    {
      "id": "q2",
      "section": "Problem Solving",
      "type": "written",
      "prompt": "string",
      "options": [],
      "expected_answer": "grading guide",
      "rubric": ["rubric item", "rubric item"],
      "points": 8
    },
    {
      "id": "q3",
      "section": "Visual / Practical",
      "type": "image",
      "prompt": "Ask the student to upload a drawing/diagram/sketch only when needed",
      "options": [],
      "expected_answer": "what a good image should contain",
      "rubric": ["visual check", "accuracy check", "clarity check"],
      "points": 8
    }
  ]
}
''';
  }

  String _gradingPrompt({
    required GeneralExam exam,
    required GeneralExamSubmission submission,
    required String college,
    required String specialization,
    required String language,
  }) {
    final answers = exam.questions.map((question) {
      final answer = switch (question.type) {
        GeneralExamQuestionType.mcq =>
          submission.mcqAnswers[question.id] == null
              ? ''
              : question.options[submission.mcqAnswers[question.id]!],
        GeneralExamQuestionType.written =>
          submission.writtenAnswers[question.id] ?? '',
        GeneralExamQuestionType.image =>
          submission.imagePaths[question.id]?.isNotEmpty == true
              ? 'Image uploaded with this request. Grade the uploaded image against this question if visible.'
              : '',
      };

      return {
        'id': question.id,
        'section': question.section,
        'type': question.type.name,
        'prompt': question.prompt,
        'options': question.options,
        'expected_answer': question.expectedAnswer,
        'rubric': question.rubric,
        'points': question.points,
        'student_answer': answer,
      };
    }).toList();

    return '''
You are Masar's strict but fair major-level exam grader.

Context:
- College: $college
- Major: $specialization
- Response language: $language

Grade the student's answers for a General Quiz. The quiz unlocks Final Phase eligibility only if the student is good enough overall.

Rules:
- Use the expected answers and rubrics.
- Grade MCQ exactly.
- Grade written answers for correctness, specificity, and applied understanding.
- Grade image answers if an image is included. If no required image was uploaded, give no credit for that image question.
- Do not invent answers the student did not provide.
- Score from 0 to 100.
- passed is true only if score_percent >= ${exam.passingScore}.
- Give concise feedback and useful next steps.
- Return ONLY valid JSON. No markdown. No extra text.

Exam and answers:
${jsonEncode(answers)}

Return this JSON shape:
{
  "score_percent": 0,
  "passed": false,
  "feedback": "short feedback",
  "strengths": ["item"],
  "weak_areas": ["item"],
  "next_steps": ["item"]
}
''';
  }

  Future<Map<String, String>?> _imagePayload(String? path) async {
    if (path == null || path.trim().isEmpty) return null;
    final file = File(path);
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return null;
    final mimeType = lookupMimeType(path, headerBytes: bytes) ?? 'image/jpeg';
    if (!mimeType.startsWith('image/')) return null;
    return {'image': base64Encode(bytes), 'mimeType': mimeType};
  }

  GeneralExam _normalizeExam(GeneralExam exam) {
    var imageSeen = false;
    return GeneralExam(
      title: exam.title,
      instructions: exam.instructions,
      passingScore: exam.passingScore,
      questions: exam.questions
          .map((question) {
            if (question.type != GeneralExamQuestionType.image) return question;
            if (!imageSeen) {
              imageSeen = true;
              return question;
            }
            return GeneralExamQuestion(
              id: question.id,
              section: question.section,
              type: GeneralExamQuestionType.written,
              prompt:
                  '${question.prompt}\n\nDescribe what your diagram would contain and explain the reasoning in text.',
              expectedAnswer: question.expectedAnswer,
              rubric: question.rubric,
              points: question.points,
            );
          })
          .toList(growable: false),
    );
  }

  Map<String, dynamic> _asJsonMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is String) {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    throw const GeneralQuizServiceException(
      'Gemini returned invalid JSON. Please retry.',
    );
  }
}

class GeneralQuizServiceException implements Exception {
  final String message;

  const GeneralQuizServiceException(this.message);

  @override
  String toString() => message;
}
