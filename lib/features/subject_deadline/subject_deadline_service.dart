import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'subject_deadline_model.dart';

class SubjectDeadlineService {
  static const String _key = 'masar_subject_deadlines_v1';

  Future<SubjectDeadline?> getDeadline(String subjectId) async {
    final all = await _loadAll();
    return all[subjectId];
  }

  Future<SubjectDeadline> setMonthTarget({
    required String subjectId,
    required int months,
  }) async {
    final now = DateTime.now();
    final deadline = SubjectDeadline(
      subjectId: subjectId,
      startDate: now,
      targetDate: DateTime(now.year, now.month + months, now.day),
      targetMonths: months,
    );
    final all = await _loadAll();
    all[subjectId] = deadline;
    await _saveAll(all);
    return deadline;
  }

  Future<SubjectDeadline?> recordCompletion(String subjectId) async {
    final all = await _loadAll();
    final deadline = all[subjectId];
    if (deadline == null) return null;

    final completedOnTime = !DateTime.now().isAfter(deadline.targetDate);
    final updated = deadline.copyWith(
      completedOnTime: completedOnTime,
      completedLate: !completedOnTime,
      deadlineBonus: completedOnTime ? 10 : 0,
    );
    all[subjectId] = updated;
    await _saveAll(all);
    return updated;
  }

  Future<void> resetCompletion(String subjectId) async {
    final all = await _loadAll();
    final deadline = all[subjectId];
    if (deadline == null) return;

    all[subjectId] = deadline.copyWith(
      completedOnTime: false,
      completedLate: false,
      deadlineBonus: 0,
    );
    await _saveAll(all);
  }

  Future<DeadlineScoreSummary> getScoreSummary() async {
    final all = await _loadAll();
    final values = all.values;
    return DeadlineScoreSummary(
      onTimeSubjects: values.where((item) => item.completedOnTime).length,
      lateSubjects: values.where((item) => item.completedLate).length,
      deadlineBonusScore: values.fold<int>(
        0,
        (sum, item) => sum + item.deadlineBonus,
      ),
    );
  }

  Future<Map<String, SubjectDeadline>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(
          key,
          SubjectDeadline.fromJson(value as Map<String, dynamic>),
        ),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveAll(Map<String, SubjectDeadline> deadlines) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = deadlines.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await prefs.setString(_key, jsonEncode(encoded));
  }
}
