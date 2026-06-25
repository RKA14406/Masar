import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/services/user_profile_service.dart'; // ✅ ADD THIS
import '../phase0/phase0_home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isPreloading = false;

  Future<void> _preloadUser(User user) async {
    if (_isPreloading) return;

    _isPreloading = true;

    await UserProfileService().getCurrentUserProfile(
      forceRefresh: true,
    );

    _isPreloading = false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ⏳ Loading auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ Not logged in
        if (!snapshot.hasData) {
          // 🔥 clear cache on logout
          UserProfileService().clearCache();
          return const LoginScreen();
        }

        // ✅ Logged in → preload once
        final user = snapshot.data!;

        return FutureBuilder(
          future: _preloadUser(user),
          builder: (context, preloadSnapshot) {
            if (preloadSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return const Phase0HomeScreen();
          },
        );
      },
    );
  }
}