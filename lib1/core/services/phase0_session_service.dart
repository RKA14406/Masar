import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Phase0SessionService {
  static const String _prefix = 'phase0_session';

  Future<void> saveEntryFlow(String flowKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix.entry_flow', flowKey);
  }

  Future<String?> getEntryFlow() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix.entry_flow');
  }

  Future<void> saveFitAnswers(List<Map<String, dynamic>> answers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix.fit_answers', jsonEncode(answers));
  }

  Future<List<Map<String, dynamic>>> getFitAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix.fit_answers');
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveInterestProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix.interest_profile', jsonEncode(profile));
  }

  Future<Map<String, dynamic>?> getInterestProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix.interest_profile');
    if (raw == null || raw.isEmpty) return null;

    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveChatQuestions(List<String> questions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('$_prefix.chat_questions', questions);
  }

  Future<List<String>> getChatQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('$_prefix.chat_questions') ?? const [];
  }

  Future<void> saveChatTranscript(List<Map<String, dynamic>> messages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix.chat_transcript', jsonEncode(messages));
  }

  Future<List<Map<String, dynamic>>> getChatTranscript() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix.chat_transcript');
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveChatSummary(String summary) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix.chat_summary', summary);
  }

  Future<String?> getChatSummary() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix.chat_summary');
  }

  Future<void> saveAptitudeSummary(Map<String, dynamic> summary) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix.aptitude_summary', jsonEncode(summary));
  }

  Future<Map<String, dynamic>?> getAptitudeSummary() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix.aptitude_summary');
    if (raw == null || raw.isEmpty) return null;

    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveRecommendations(List<Map<String, dynamic>> recommendations) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix.recommendations', jsonEncode(recommendations));
  }

  Future<List<Map<String, dynamic>>> getRecommendations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix.recommendations');
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveChosenSpecialtyKey(String specialtyKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix.chosen_specialty_key', specialtyKey);
  }

  Future<String?> getChosenSpecialtyKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix.chosen_specialty_key');
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_prefix)).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
