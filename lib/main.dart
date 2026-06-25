import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ ADD THIS
import 'app/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/settings_service.dart';
import 'core/services/user_profile_service.dart'; // ✅ ADD THIS

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");

  final settingsService = SettingsService();

  // 🔥 ONLY ADD THIS BLOCK
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await UserProfileService().getCurrentUserProfile();
  }

  runApp(MasarApp(settingsService: settingsService));
}

