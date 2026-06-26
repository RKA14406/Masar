import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  // 🔥 SINGLETON
  static final UserProfileService _instance =
  UserProfileService._internal();

  factory UserProfileService() => _instance;

  UserProfileService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, dynamic>? _cachedProfile;

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
    final data = {
      'username': username,
      'age': age,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(uid).set(data);

    _cachedProfile = data; // instant update
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

    try {
      final doc =
      await _firestore.collection('users').doc(user.uid).get();

      if (!doc.exists) return null;

      _cachedProfile = doc.data();
      return _cachedProfile;
    } catch (_) {
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
}