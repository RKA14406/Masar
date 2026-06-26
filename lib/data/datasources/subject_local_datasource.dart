import 'dart:convert';
import 'package:flutter/services.dart';

import '../../core/services/app_data_service.dart';
import '../models/subject_model.dart';

class SubjectLocalDataSource {
  static const String _datasetPath =
      'assets/data/vision_career_phase1_phase2_master_dataset_rebuilt.json';

  static List<Subject>? _cache;

  Future<List<Subject>> loadAllSubjects() async {
    if (_cache != null) {
      return List<Subject>.unmodifiable(_cache!);
    }

    List<dynamic> raw;

    try {
      // Primary: fetch from backend
      raw = await AppDataService().fetchSubjects();
    } catch (_) {
      // Fallback: local asset bundle (offline / backend unavailable)
      final jsonStr = await rootBundle.loadString(_datasetPath);
      raw = json.decode(jsonStr) as List<dynamic>;
    }

    _cache = raw
        .whereType<Map<String, dynamic>>()
        .map((item) => Subject.fromJson(item))
        .toList(growable: false);

    return List<Subject>.unmodifiable(_cache!);
  }

  Future<List<Subject>> loadSubjectsBySpecialization(String specialization) async {
    final allSubjects = await loadAllSubjects();
    final normalizedSpecialization = _normalize(specialization);

    return allSubjects
        .where(
          (subject) => _normalize(subject.specialization) == normalizedSpecialization,
        )
        .toList(growable: false);
  }

  Future<List<Subject>> loadSubjectsByCollegeAndSpecialization({
    required String college,
    required String specialization,
  }) async {
    final allSubjects = await loadAllSubjects();
    final normalizedCollege = _normalize(college);
    final normalizedSpecialization = _normalize(specialization);

    return allSubjects
        .where(
          (subject) =>
              _normalize(subject.college) == normalizedCollege &&
              _normalize(subject.specialization) == normalizedSpecialization,
        )
        .toList(growable: false);
  }

  Future<List<String>> loadAvailableColleges() async {
    final allSubjects = await loadAllSubjects();

    final names = allSubjects
        .map((subject) => subject.college.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }

  Future<List<String>> loadAvailableSpecializations() async {
    final allSubjects = await loadAllSubjects();

    final names = allSubjects
        .map((subject) => subject.specialization.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }

  Future<List<String>> loadAvailableSpecializationsByCollege(String college) async {
    final allSubjects = await loadAllSubjects();
    final normalizedCollege = _normalize(college);

    final names = allSubjects
        .where((subject) => _normalize(subject.college) == normalizedCollege)
        .map((subject) => subject.specialization.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }

  String _normalize(String value) => value.trim().toLowerCase();
}
