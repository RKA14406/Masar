import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AppDataService {
  AppDataService._internal();
  static final AppDataService _instance = AppDataService._internal();
  factory AppDataService() => _instance;

  static const String _url = 'https://vision-career.onrender.com/data';
  static const String _assetPath =
      'assets/data/vision_career_phase1_phase2_master_dataset_rebuilt.json';

  List<dynamic>? _cache;

  Future<List<dynamic>> fetchSubjects() async {
    if (_cache != null) return _cache!;

    _cache = await _loadFallbackData();
    unawaited(_refreshFromBackend());
    return _cache!;
  }

  Future<void> _refreshFromBackend() async {
    try {
      final response = await http
          .get(Uri.parse(_url))
          .timeout(const Duration(seconds: 4));

      debugPrint(
        'AppDataService response ${response.statusCode}, ${response.body.length} bytes',
      );

      if (response.statusCode != 200) {
        throw Exception('AppDataService: HTTP ${response.statusCode}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true) {
        throw Exception('AppDataService: ${body['error'] ?? 'Unknown error'}');
      }

      final data = body['data'];
      if (data is! List || data.isEmpty) {
        throw Exception('AppDataService: Missing or invalid data field');
      }

      _cache = data;
    } catch (error) {
      debugPrint(
        'AppDataService remote refresh skipped, using local data: $error',
      );
    }
  }

  void clearCache() => _cache = null;

  Future<List<dynamic>> _loadFallbackData() async {
    try {
      final raw = await rootBundle.loadString(_assetPath);
      if (raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List<dynamic> && decoded.isNotEmpty) {
          return decoded;
        }
        if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          final data = decoded['data'] as List<dynamic>;
          if (data.isNotEmpty) return data;
        }
      }
    } catch (error) {
      debugPrint('AppDataService asset fallback unavailable: $error');
    }

    return _builtInDemoSubjects();
  }

  List<Map<String, dynamic>> _builtInDemoSubjects() {
    const tracks = [
      _FallbackTrack(
        college: 'Information Technology',
        collegeAr: 'تكنولوجيا المعلومات',
        specialization: 'Artificial Intelligence',
        specializationAr: 'الذكاء الاصطناعي',
        codes: ['AI101', 'AI102', 'AI201', 'AI202'],
        names: [
          'Programming Fundamentals',
          'Discrete Mathematics',
          'Machine Learning Basics',
          'AI Project Studio',
        ],
        skills: ['Python', 'Problem Solving', 'Machine Learning'],
      ),
      _FallbackTrack(
        college: 'Information Technology',
        collegeAr: 'تكنولوجيا المعلومات',
        specialization: 'Cybersecurity',
        specializationAr: 'الأمن السيبراني',
        codes: ['CY101', 'CY102', 'CY201', 'CY202'],
        names: [
          'Networking Fundamentals',
          'Linux Basics',
          'Security Principles',
          'Defensive Security Lab',
        ],
        skills: ['Networking', 'Linux', 'Security Analysis'],
      ),
      _FallbackTrack(
        college: 'Engineering',
        collegeAr: 'الهندسة',
        specialization: 'Aerospace Engineering',
        specializationAr: 'هندسة الطيران والفضاء',
        codes: ['AE101', 'AE102', 'AE201', 'AE202'],
        names: [
          'Engineering Mathematics',
          'Physics for Engineers',
          'Aerodynamics Basics',
          'Space Systems Project',
        ],
        skills: ['Physics', 'CAD', 'Systems Thinking'],
      ),
      _FallbackTrack(
        college: 'Science',
        collegeAr: 'العلوم',
        specialization: 'Data Science',
        specializationAr: 'علم البيانات',
        codes: ['DS101', 'DS102', 'DS201', 'DS202'],
        names: [
          'Statistics Foundations',
          'Python for Data',
          'Data Visualization',
          'Applied Data Project',
        ],
        skills: ['Statistics', 'Python', 'Data Visualization'],
      ),
    ];

    final subjects = <Map<String, dynamic>>[];
    for (final track in tracks) {
      for (var i = 0; i < track.codes.length; i++) {
        subjects.add({
          'college': track.college,
          'college_ar': track.collegeAr,
          'specialization': track.specialization,
          'specialization_ar': track.specializationAr,
          'phase': i < 2 ? 1 : 2,
          'code': track.codes[i],
          'name': track.names[i],
          'name_ar': track.names[i],
          'credits': 3,
          'prerequisites': i == 0 ? <String>[] : <String>[track.codes[i - 1]],
          'description':
              'Demo-safe fallback subject used when the remote Masar dataset is unavailable.',
          'description_ar':
              'مادة تجريبية احتياطية عند تعذر الوصول إلى بيانات مسار.',
          'resources': <String>[],
          'skills': track.skills,
        });
      }
    }

    return subjects;
  }
}

class _FallbackTrack {
  final String college;
  final String collegeAr;
  final String specialization;
  final String specializationAr;
  final List<String> codes;
  final List<String> names;
  final List<String> skills;

  const _FallbackTrack({
    required this.college,
    required this.collegeAr,
    required this.specialization,
    required this.specializationAr,
    required this.codes,
    required this.names,
    required this.skills,
  });
}
