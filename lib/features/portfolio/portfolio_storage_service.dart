import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'portfolio_model.dart';

class PortfolioStorageService {
  static const String _guestKey = 'masar_portfolio_guest';

  String get _storageKey {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return _guestKey;
    return 'masar_portfolio_$uid';
  }

  Future<void> savePortfolio(SavedPortfolio portfolio) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(portfolio.toJson()));
  }

  Future<SavedPortfolio?> loadPortfolio() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return null;

    try {
      return SavedPortfolio.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasSavedPortfolio() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_storageKey);
  }
}
