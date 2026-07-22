import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF0D1B3E);
  static const Color primaryLight = Color(0xFF1A2F5A);
  static const Color primaryDark = Color(0xFF081228);
  static const Color accent = Color(0xFF6C63FF);
  static const Color accentLight = Color(0xFF8B85FF);

  // Background
  static const Color background = Color(0xFF0A1628);
  static const Color surface = Color(0xFF111F3E);
  static const Color surfaceLight = Color(0xFF1A2F5A);
  static const Color card = Color(0xFF142040);
  static const Color cardHover = Color(0xFF1E2D52);

  // Sidebar
  static const Color sidebar = Color(0xFF0D1B3E);
  static const Color sidebarActive = Color(0xFF6C63FF);
  static const Color sidebarText = Color(0xFFB0BEC5);
  static const Color sidebarActiveText = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted = Color(0xFF607D8B);
  static const Color textHint = Color(0xFF546E7A);

  // Status
  static const Color success = Color(0xFF00C853);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFFD600);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFFF1744);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF00B0FF);
  static const Color infoLight = Color(0xFFE1F5FE);

  // Border
  static const Color border = Color(0xFF1E3A6B);
  static const Color borderLight = Color(0xFF263C6B);
  static const Color divider = Color(0xFF1A2F5A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D1B3E), Color(0xFF1A2F5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFFD600), Color(0xFFFF6D00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFFF1744), Color(0xFFD500F9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient infoGradient = LinearGradient(
    colors: [Color(0xFF00B0FF), Color(0xFF6C63FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
