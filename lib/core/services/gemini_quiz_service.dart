import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/gemini_quiz_config.dart';
import '../../data/models/quiz_models.dart';
import '../../data/models/subject_model.dart';

class GeminiQuizService {
  const GeminiQuizService();

  Future<GeneratedQuiz> generateDynamicQuiz({
    required Subject subject,
    required String college,
    required String specialization,
    required String achievementsSummary,
    String language = 'English',
  }) async {
    try {
      final prompt = _buildPrompt(
        subject: subject,
        college: college,
        specialization: specialization,
        achievementsSummary: achievementsSummary,
        responseLanguage: _normalizeResponseLanguage(language),
      );

      final response = await http.post(
        Uri.parse(GeminiQuizConfig.backendUrl),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Quiz backend request failed (${response.statusCode}): ${response.body}',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (body['success'] != true) {
        throw Exception('AI failed: ${body['error']}');
      }

      final jsonData = Map<String, dynamic>.from(body['data'] as Map);
      final quiz = _parseGeneratedQuiz(jsonData);

      _validateQuiz(quiz);

      return quiz;
    } catch (e) {
      debugPrint('QUIZ ERROR: $e');
      return _fallbackQuiz(subject: subject, college: college);
    }
  }

  String _buildPrompt({
    required Subject subject,
    required String college,
    required String specialization,
    required String achievementsSummary,
    required String responseLanguage,
  }) {
    final normalizedCollege = college.toLowerCase().trim();

    String collegeBiasBlock;
    if (_isITCollege(normalizedCollege)) {
      collegeBiasBlock = '''
College-level assessment tendency:
- This subject belongs to an IT-related college.
- Writing/code/explanation quizzes should be MORE LIKELY overall.
- Target tendency across many IT subjects: about 60% writing, 30% mcq, 10% image.
- This is ONLY a soft probability tendency.
- For theoretical math, logic, or memorization-heavy subjects, mcq may still be better.
- Do NOT choose writing just because the college is IT if the exact subject does not fit.''';
    } else if (_isEngineeringCollege(normalizedCollege)) {
      collegeBiasBlock = '''
College-level assessment tendency:
- This subject belongs to an engineering-related college.
- Image/practical/diagram-style quizzes should be MORE LIKELY overall.
- Target tendency across many engineering subjects: about 60% image, 25% writing, 15% mcq.
- This is ONLY a soft probability tendency.
- For theoretical math, logic, or memorization-heavy subjects, mcq may still be better.
- Do NOT choose image just because the college is engineering if the exact subject does not fit.''';
    } else {
      collegeBiasBlock = '''
College-level assessment tendency:
- No special college bias.
- Choose the most educationally suitable quiz type for the exact subject.''';
    }

    return '''
You are the assessment generation engine for Masar.

Your job is to generate ONE academically suitable quiz for ONE university subject.

SUBJECT CONTEXT:
- College: $college
- Specialization: $specialization
- Subject code: ${subject.code}
- Subject name: ${subject.name}
- Description: ${subject.description}
- Skills: ${subject.skills.join(', ')}
- Achievements summary: $achievementsSummary

$collegeBiasBlock

QUIZ SELECTION RULES:
- Allowed quiz types: mcq, writing, image
- Choose the quiz type based FIRST on the exact subject itself, not only the college.
- MCQ is best for theory, definitions, facts, formulas, conceptual recall, logic, and mathematics.
- Writing is best for programming, code reasoning, technical explanation, algorithm tracing, problem solving, and open-ended applied answers.
- Image is best for drawing, sketching, diagramming, UI/layout recreation, circuit/visual design, architecture plans, and other truly visual submissions.
- Never choose image unless the subject naturally benefits from a visual submission.
- Never choose writing unless open-ended reasoning or coding makes sense.
- Never force a college-level tendency when the exact subject does not fit it.
- Discrete math, calculus, statistics, and other math-heavy subjects will usually fit MCQ better unless there is a very clear reason otherwise.

OUTPUT RULES:
- Return EXACTLY ONE quiz
- You MUST return ONLY valid JSON
- Your entire response MUST be a single JSON object
- Do NOT include any text before or after the JSON
- Do NOT include markdown or ```json blocks
- Do NOT include explanations
- Never return empty required fields
- If you cannot follow the format exactly, return {}

JSON FORMAT:
{
  "quiz_type": "mcq | writing | image",
  "instructions": "short instructions",

  "questions": [
    {
      "question": "string",
      "choices": ["A", "B", "C", "D"],
      "correct_answer_index": 0,
      "explanation": "string",
      "difficulty_tag": "easy|medium|hard"
    }
  ],

  "writing_prompt": "string",
  "image_task": "string",
  "image_rubric": ["string", "string"],
  "passing_score": 60
}

VALIDITY RULES:
- If quiz_type = mcq:
  - questions must contain 20 to 30 valid questions
  - each question must have exactly 4 meaningful choices
  - correct_answer_index must be 0 to 3
  - writing_prompt can be empty
  - image_task can be empty
  - image_rubric can be empty
- If quiz_type = writing:
  - writing_prompt must be non-empty
  - questions can be empty
  - image_task can be empty
  - image_rubric can be empty
- If quiz_type = image:
  - image_task must be non-empty
  - image_rubric must contain 3 to 6 clear rubric checks
  - questions can be empty
  - writing_prompt can be empty

Now generate the quiz.
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

  bool _isITCollege(String normalizedCollege) {
    return normalizedCollege.contains('it') ||
        normalizedCollege.contains('information technology') ||
        normalizedCollege.contains('computer science') ||
        normalizedCollege.contains('computing') ||
        normalizedCollege.contains('software');
  }

  bool _isEngineeringCollege(String normalizedCollege) {
    return normalizedCollege.contains('engineering') ||
        normalizedCollege.contains('engineer');
  }

  GeneratedQuiz _parseGeneratedQuiz(Map<String, dynamic> json) {
    final typeStr = (json['quiz_type'] ?? '').toString().trim().toLowerCase();

    final QuizType type;
    switch (typeStr) {
      case 'writing':
        type = QuizType.writing;
        break;
      case 'image':
        type = QuizType.image;
        break;
      case 'mcq':
      default:
        type = QuizType.mcq;
        break;
    }

    final instructions = (json['instructions'] ?? '').toString().trim();

    final rawQuestions = json['questions'] as List<dynamic>? ?? const [];
    final mcqQuestions = rawQuestions
        .whereType<Map<String, dynamic>>()
        .map((q) => {
              'question': (q['question'] ?? '').toString(),
              'choices': (q['choices'] as List<dynamic>? ?? const [])
                  .map((c) => c.toString())
                  .toList(growable: false),
              'correct_answer_index': q['correct_answer_index'],
              'explanation': (q['explanation'] ?? '').toString(),
              'difficulty_tag': (q['difficulty_tag'] ?? 'medium').toString(),
            })
        .toList(growable: false);

    final imageRubric = (json['image_rubric'] as List<dynamic>? ?? const [])
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    final passingScoreRaw = json['passing_score'];
    final passingScore = passingScoreRaw is int
        ? passingScoreRaw
        : int.tryParse(passingScoreRaw.toString()) ?? 60;

    return GeneratedQuiz(
      type: type,
      instructions: instructions.isEmpty ? 'Complete the quiz carefully.' : instructions,
      mcqQuestions: mcqQuestions,
      writingPrompt: (json['writing_prompt'] ?? '').toString().trim(),
      imageTask: (json['image_task'] ?? '').toString().trim(),
      imageRubric: imageRubric,
      passingScore: passingScore.clamp(1, 100),
    );
  }

  void _validateQuiz(GeneratedQuiz quiz) {
    switch (quiz.type) {
      case QuizType.mcq:
        if (quiz.mcqQuestions == null || quiz.mcqQuestions!.isEmpty) {
          throw const FormatException('MCQ quiz returned no questions.');
        }
        final parsed = quiz.parsedMcqQuestions;
        if (parsed.length < 20 || parsed.length > 30) {
          throw const FormatException('MCQ quiz returned too few valid questions.');
        }
        break;

      case QuizType.writing:
        if ((quiz.writingPrompt ?? '').trim().isEmpty) {
          throw const FormatException('Writing quiz missing prompt.');
        }
        break;

      case QuizType.image:
        if ((quiz.imageTask ?? '').trim().isEmpty) {
          throw const FormatException('Image quiz missing task.');
        }
        if (quiz.imageRubric.length < 3) {
          throw const FormatException('Image quiz missing rubric checks.');
        }
        break;
    }
  }

  GeneratedQuiz _fallbackQuiz({
    required Subject subject,
    required String college,
  }) {
    final combined = '${subject.name} ${subject.description} ${subject.skills.join(' ')}'.toLowerCase();

    final looksLikeProgramming = combined.contains('programming') ||
        combined.contains('coding') ||
        combined.contains('algorithm') ||
        combined.contains('java') ||
        combined.contains('python') ||
        combined.contains('oop') ||
        combined.contains('software');

    final looksLikeVisual = combined.contains('drawing') ||
        combined.contains('ui') ||
        combined.contains('ux') ||
        combined.contains('layout') ||
        combined.contains('diagram') ||
        combined.contains('design sketch');

    if (looksLikeVisual) {
      return GeneratedQuiz(
        type: QuizType.image,
        instructions: 'Upload a clear image that matches the task.',
        imageTask:
            'Create a visual submission related to ${subject.name} and upload a clear image of your work.',
        imageRubric: const [
          'The image is clear and readable',
          'The submission matches the requested visual task',
          'The work shows correct core subject understanding',
        ],
        passingScore: 60,
      );
    }

    if (looksLikeProgramming || _isITCollege(college.toLowerCase())) {
      return GeneratedQuiz(
        type: QuizType.writing,
        instructions: 'Answer clearly and with technical accuracy.',
        writingPrompt:
            'Explain one important concept from ${subject.name} and show how it is applied in practice.',
        passingScore: 60,
      );
    }

    return GeneratedQuiz(
      type: QuizType.mcq,
      instructions: 'Choose the best answer for each question.',
      mcqQuestions: [
        {
          'question': 'Which statement best describes the main focus of ${subject.name}?',
          'choices': [
            'It studies core concepts and practical understanding of the subject',
            'It is only about memorizing unrelated facts',
            'It has no connection to the specialization',
            'It replaces every other subject in the study plan'
          ],
          'correct_answer_index': 0,
          'explanation': 'University subjects focus on core concepts and practical understanding.',
          'difficulty_tag': 'easy',
        },
        {
          'question': 'Why is ${subject.name} important in ${subject.specialization}?',
          'choices': [
            'Because it builds useful knowledge and skills for later subjects',
            'Because it removes the need to study prerequisites',
            'Because it is unrelated to academic progress',
            'Because it is only taken for attendance'
          ],
          'correct_answer_index': 0,
          'explanation': 'Subjects are included because they support future learning and skill building.',
          'difficulty_tag': 'easy',
        },
        {
          'question': 'What is the best way to succeed in ${subject.name}?',
          'choices': [
            'Understand the concepts and practice regularly',
            'Ignore the main ideas and guess randomly',
            'Only memorize titles without understanding',
            'Skip all practice and examples'
          ],
          'correct_answer_index': 0,
          'explanation': 'Understanding plus practice is the strongest strategy for academic success.',
          'difficulty_tag': 'easy',
        },
      ],
      passingScore: 60,
    );
  }
}
