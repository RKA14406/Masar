import 'package:flutter/material.dart';

import '../features/college_selection/college_selection_screen.dart';
import '../features/specialization_selection/specialization_selection_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/career/browse_tracks_screen.dart';
import '../features/cv_generator/cv_builder_screen.dart';
import '../features/seven_sabak/seven_sabak_hub_screen.dart';
import '../features/main/main_navigation_shell.dart';
import '../features/home/home_screen.dart';
import '../features/comp_finder/comp_finder_screen.dart';
import '../features/ada2k/ada2k_screen.dart';

class AppRoutes {
  static const String phase0Home = '/';
  static const String collegeSelection = '/college-selection';
  static const String specializationSelection = '/specializations';
  static const String login = '/login';
  static const String register = '/register';
  static const String browseTracks = '/browse-tracks';
  static const String cvGenerator = '/cv-generator';
  static const String sevenSabak = '/seven-sabak';
  
  // New main shell routes
  static const String mainShell = '/main';
  static const String home = '/home';
  static const String masark = '/masark';
  static const String compFinder = '/comp-finder';
  static const String ada2k = '/ada2k';

  static Map<String, WidgetBuilder> routes() {
    return {
      collegeSelection: (_) => const CollegeSelectionScreen(),
      specializationSelection: (_) => const SpecializationSelectionScreen(),
      login: (_) => const LoginScreen(),
      register: (_) => const RegisterScreen(),
      browseTracks: (_) => const BrowseTracksScreen(),
      cvGenerator: (_) => const CvBuilderScreen(),
      sevenSabak: (_) => const SevenSabakHubScreen(),
      mainShell: (_) => const MainNavigationShell(),
      home: (_) => const HomeScreen(),
      compFinder: (_) => const CompFinderScreen(),
      ada2k: (_) => const Ada2kScreen(),
    };
  }
}
