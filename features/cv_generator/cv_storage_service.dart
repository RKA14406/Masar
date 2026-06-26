import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cv_model.dart';

class CvStorageService {
  static const String _guestKey = 'masar_cv_guest';

  String get _storageKey {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return _guestKey;
    return 'masar_cv_$uid';
  }

  Future<void> saveCv(SavedCv cv) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(cv.toJson()));
  }

  Future<SavedCv?> loadCv() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      return SavedCv.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }
}
