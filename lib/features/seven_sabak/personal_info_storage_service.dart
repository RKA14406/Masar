import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'personal_info_model.dart';

class PersonalInfoStorageService {
  static const String _guestKey = 'masar_personal_info_guest';

  String get _key {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid == null || uid.isEmpty ? _guestKey : 'masar_personal_info_$uid';
  }

  Future<void> save(PersonalInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(info.toJson()));
  }

  Future<PersonalInfo?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;

    try {
      return PersonalInfo.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
