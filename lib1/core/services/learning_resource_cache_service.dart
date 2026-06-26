import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/learning_resource_model.dart';

class LearningResourceCacheService {
  static String _key(String subjectCode) => 'resources_$subjectCode';

  Future<List<LearningResource>?> getCachedResources(String subjectCode) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(subjectCode));

    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;

      return decoded
          .map(
            (item) => LearningResource.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveCachedResources(
    String subjectCode,
    List<LearningResource> resources,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      resources.map((resource) => resource.toJson()).toList(),
    );

    await prefs.setString(_key(subjectCode), encoded);
  }

  Future<void> clearCachedResources(String subjectCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(subjectCode));
  }
}