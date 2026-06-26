import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QuizAttemptLimitService {
  static const int maxAttemptsPerDay = 3;

  String _storageKey(String specialization, String subjectCode) {
    final safeSpec = specialization.replaceAll(' ', '_');
    return 'quiz_attempts_${safeSpec}_$subjectCode';
  }

  String _todayKey() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Get how many attempts the user used today
  Future<int> getTodayAttempts({
    required String specialization,
    required String subjectCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey(specialization, subjectCode));

    if (raw == null || raw.isEmpty) return 0;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final today = _todayKey();

      if (decoded['date'] != today) {
        return 0; // reset automatically if new day
      }

      final attempts = decoded['attempts'];
      if (attempts is int) return attempts;

      return int.tryParse(attempts.toString()) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Remaining attempts today
  Future<int> getRemainingAttempts({
    required String specialization,
    required String subjectCode,
  }) async {
    final used = await getTodayAttempts(
      specialization: specialization,
      subjectCode: subjectCode,
    );

    final remaining = maxAttemptsPerDay - used;
    return remaining < 0 ? 0 : remaining;
  }

  /// Can user start a new attempt?
  Future<bool> canStartAttempt({
    required String specialization,
    required String subjectCode,
  }) async {
    final used = await getTodayAttempts(
      specialization: specialization,
      subjectCode: subjectCode,
    );

    return used < maxAttemptsPerDay;
  }

  /// Register a new attempt (called when quiz starts)
  Future<void> registerAttempt({
    required String specialization,
    required String subjectCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final today = _todayKey();
    final used = await getTodayAttempts(
      specialization: specialization,
      subjectCode: subjectCode,
    );

    final payload = <String, dynamic>{
      'date': today,
      'attempts': used + 1,
    };

    await prefs.setString(
      _storageKey(specialization, subjectCode),
      jsonEncode(payload),
    );
  }

  /// Reset attempts manually (optional, for testing/admin)
  Future<void> resetAttempts({
    required String specialization,
    required String subjectCode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey(specialization, subjectCode));
  }
}