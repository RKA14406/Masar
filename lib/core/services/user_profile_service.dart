import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileService {
  static const Duration _remoteTimeout = Duration(seconds: 4);

  // 🔥 SINGLETON
  static final UserProfileService _instance = UserProfileService._internal();

  factory UserProfileService() => _instance;

  UserProfileService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _cachedProfile;

  String _localProfileKey(String uid) => 'masar_user_profile_$uid';

  // 🔥 PUBLIC ACCESS
  Map<String, dynamic>? get cachedProfile => _cachedProfile;

  bool get hasCache => _cachedProfile != null;

  // ─────────────────────────────────────────────
  // SAVE PROFILE
  // ─────────────────────────────────────────────
  Future<void> saveUserProfile({
    required String uid,
    required String username,
    required int age,
    required String email,
  }) async {
    final localData = {
      'username': username,
      'age': age,
      'email': email,
      'createdAt': DateTime.now().toIso8601String(),
    };

    _cachedProfile = localData;
    await _saveLocalProfile(uid, localData);

    unawaited(
      _saveRemoteProfile(uid: uid, username: username, age: age, email: email),
    );
  }

  Future<void> _saveRemoteProfile({
    required String uid,
    required String username,
    required int age,
    required String email,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set({
            'username': username,
            'age': age,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
          })
          .timeout(_remoteTimeout);
    } catch (error) {
      debugPrint('UserProfileService remote save skipped: $error');
    }
  }

  // ─────────────────────────────────────────────
  // GET PROFILE (SMART)
  // ─────────────────────────────────────────────
  Future<Map<String, dynamic>?> getCurrentUserProfile({
    bool forceRefresh = false,
  }) async {
    // ✅ HARD STOP → no fetch
    if (!forceRefresh && _cachedProfile != null) {
      return _cachedProfile;
    }

    final user = _auth.currentUser;
    if (user == null) return null;
    final localProfile = await _loadLocalProfile(user.uid);

    if (!forceRefresh && localProfile != null) {
      _cachedProfile = localProfile;
      unawaited(_refreshRemoteProfile(user.uid));
      return _cachedProfile;
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(_remoteTimeout);

      if (!doc.exists) return localProfile;

      _cachedProfile = doc.data();
      if (_cachedProfile != null) {
        await _saveLocalProfile(user.uid, _cachedProfile!);
      }
      return _cachedProfile;
    } catch (error) {
      debugPrint('UserProfileService remote fetch skipped: $error');
      _cachedProfile = localProfile ?? _cachedProfile;
      return _cachedProfile;
    }
  }

  // ─────────────────────────────────────────────
  // PRELOAD (NEW)
  // ─────────────────────────────────────────────
  Future<void> preload() async {
    if (_cachedProfile != null) return; // 🔥 skip fetch

    await getCurrentUserProfile();
  }

  // ─────────────────────────────────────────────
  // CLEAR
  // ─────────────────────────────────────────────
  void clearCache() {
    _cachedProfile = null;
  }

  Future<void> _refreshRemoteProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .get()
          .timeout(_remoteTimeout);
      if (!doc.exists) return;
      final data = doc.data();
      if (data == null) return;
      _cachedProfile = data;
      await _saveLocalProfile(uid, data);
    } catch (error) {
      debugPrint('UserProfileService background refresh skipped: $error');
    }
  }

  Future<void> _saveLocalProfile(
    String uid,
    Map<String, dynamic> profile,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final safeProfile = profile.map(
      (key, value) => MapEntry(key, _jsonSafeValue(value)),
    );
    await prefs.setString(_localProfileKey(uid), jsonEncode(safeProfile));
  }

  Future<Map<String, dynamic>?> _loadLocalProfile(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localProfileKey(uid));
    if (raw == null || raw.isEmpty) return null;

    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Object? _jsonSafeValue(Object? value) {
    if (value == null ||
        value is String ||
        value is num ||
        value is bool ||
        value is List ||
        value is Map) {
      return value;
    }
    if (value is Timestamp) return value.toDate().toIso8601String();
    return value.toString();
  }
}
