import 'package:flutter/material.dart';

import '../features/college_selection/college_selection_screen.dart';
import '../features/specialization_selection/specialization_selection_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/career/browse_tracks_screen.dart';

class AppRoutes {
  static const String phase0Home = '/';
  static const String collegeSelection = '/college-selection';
  static const String specializationSelection = '/specializations';
  static const String login = '/login';
  static const String register = '/register';
  static const String browseTracks = '/browse-tracks';

  static Map<String, WidgetBuilder> routes() {
    return {
      collegeSelection: (_) => const CollegeSelectionScreen(),
      specializationSelection: (_) => const SpecializationSelectionScreen(),
      login: (_) => const LoginScreen(),
      register: (_) => const RegisterScreen(),
      browseTracks: (_) => const BrowseTracksScreen(),
    };
  }
}