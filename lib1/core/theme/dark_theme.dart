import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  scaffoldBackgroundColor: AppColors.darkBackground,

  colorScheme: ColorScheme.dark(
    primary: AppColors.gold,
    secondary: AppColors.gold,
    surface: AppColors.darkSurface,
    background: AppColors.darkBackground,
    onPrimary: Colors.black,
    onSurface: AppColors.darkTextPrimary,
  ),

  textTheme: AppTextTheme.darkTextTheme,

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkBackground,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
    titleTextStyle: TextStyle(
      color: AppColors.darkTextPrimary,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  cardTheme: CardThemeData(
    color: AppColors.darkSurface,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.gold,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);