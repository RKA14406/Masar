import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/services/user_profile_service.dart';
import '../main/main_navigation_shell.dart';
import 'auth_loading_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AuthLoadingScreen();
        }

        if (!snapshot.hasData) {
          UserProfileService().clearCache();
          return const LoginScreen();
        }

        unawaited(UserProfileService().getCurrentUserProfile());
        return const MainNavigationShell();
      },
    );
  }
}
