import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        useMaterial3: false,
      );
}
