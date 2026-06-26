import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'general_quiz_model.dart';

class GeneralQuizStorageService {
  static String _key(String specialization) =>
      'masar_general_quiz_${specialization.trim().replaceAll(' ', '_')}';

  Future<GeneralQuizStatus> loadStatus(String specialization) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(specialization));
    if (raw == null || raw.isEmpty) return const GeneralQuizStatus();

    try {
      return GeneralQuizStatus.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const GeneralQuizStatus();
    }
  }

  Future<GeneralQuizStatus> saveAttempt({
    required String specialization,
    required int scorePercent,
    required bool passed,
    bool usedDeveloperSkip = false,
  }) async {
    final current = await loadStatus(specialization);
    final now = DateTime.now();
    final attempt = GeneralQuizAttempt(
      scorePercent: scorePercent,
      passed: passed,
      attemptedAt: now,
      usedDeveloperSkip: usedDeveloperSkip,
    );
    final status = GeneralQuizStatus(
      attempts: [...current.attempts, attempt],
      latestScore: scorePercent,
      passed: current.passed || passed,
      passedAt: passed ? now : current.passedAt,
      finalPhaseEligibleByGeneralQuiz:
          current.finalPhaseEligibleByGeneralQuiz || passed,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(specialization), jsonEncode(status.toJson()));
    return status;
  }
}
