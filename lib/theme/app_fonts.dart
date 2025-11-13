import 'package:flutter/material.dart';
import 'package:keep_notes_clone/theme/app_colors.dart';

class AppFonts {
  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
  );

  static const TextStyle noteTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle noteContent = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
  );
  // Add subheading style:
  static TextStyle subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
}
