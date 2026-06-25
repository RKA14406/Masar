import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/subject_model.dart';
import 'career_llm_service.dart';

class CareerStorageService {
  String _safeKeyPart(String value) =>
      value.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');

  String _scopeKey({
    required String college,
    required String specialization,
  }) =>
      '${_safeKeyPart(college)}__${_safeKeyPart(specialization)}';

  String _jobsKey({
    required String college,
    required String specialization,
  }) =>
      'career_jobs_${_scopeKey(college: college, specialization: specialization)}';

  String _selectedJobsKey({
    required String college,
    required String specialization,
  }) =>
      'career_selected_jobs_${_scopeKey(college: college, specialization: specialization)}';

  String _nodesKey({
    required String college,
    required String specialization,
  }) =>
      'career_phase3_nodes_${_scopeKey(college: college, specialization: specialization)}';

  String _generatedKey({
    required String college,
    required String specialization,
  }) =>
      'career_phase3_generated_${_scopeKey(college: college, specialization: specialization)}';

  Future<void> saveSuggestedJobs({
    required String college,
    required String specialization,
    required List<CareerJobSuggestion> jobs,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(jobs.map((job) => job.toJson()).toList());
    await prefs.setString(
      _jobsKey(college: college, specialization: specialization),
      encoded,
    );
  }

  Future<List<CareerJobSuggestion>> loadSuggestedJobs({
    required String college,
    required String specialization,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(
      _jobsKey(college: college, specialization: specialization),
    );

    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) => CareerJobSuggestion.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSelectedJobs({
    required String college,
    required String specialization,
    required List<CareerJobSuggestion> jobs,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(jobs.map((job) => job.toJson()).toList());
    await prefs.setString(
      _selectedJobsKey(college: college, specialization: specialization),
      encoded,
    );
  }

  Future<List<CareerJobSuggestion>> loadSelectedJobs({
    required String college,
    required String specialization,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(
      _selectedJobsKey(college: college, specialization: specialization),
    );

    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map(
            (item) => CareerJobSuggestion.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveGeneratedNodes({
    required String college,
    required String specialization,
    required List<Subject> nodes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(nodes.map((node) => node.toJson()).toList());

    await prefs.setString(
      _nodesKey(college: college, specialization: specialization),
      encoded,
    );
    await prefs.setBool(
      _generatedKey(college: college, specialization: specialization),
      true,
    );
  }

  Future<List<Subject>> loadGeneratedNodes({
    required String college,
    required String specialization,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(
      _nodesKey(college: college, specialization: specialization),
    );

    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Subject.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return [];
    }
  }

  Future<bool> isPhase3Generated({
    required String college,
    required String specialization,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(
          _generatedKey(college: college, specialization: specialization),
        ) ??
        false;
  }

  Future<void> clearPhase3({
    required String college,
    required String specialization,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_jobsKey(college: college, specialization: specialization));
    await prefs.remove(
      _selectedJobsKey(college: college, specialization: specialization),
    );
    await prefs.remove(_nodesKey(college: college, specialization: specialization));
    await prefs.remove(
      _generatedKey(college: college, specialization: specialization),
    );
  }
}
