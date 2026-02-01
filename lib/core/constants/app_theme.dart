import 'package:flutter/material.dart';

/// App theme configuration with Material Design 3
/// Provides light and dark theme variants with custom color schemes

class AppTheme {
  AppTheme._();

  // =============================================================================
  // BRAND COLORS
  // =============================================================================

  /// Primary brand color - Deep indigo
  static const Color primaryColor = Color(0xFF4F46E5);

  /// Secondary brand color - Purple
  static const Color secondaryColor = Color(0xFF7C3AED);

  /// Accent color - Teal
  static const Color accentColor = Color(0xFF14B8A6);

  // =============================================================================
  // STATUS COLORS
  // =============================================================================

  /// Paid payment color - Green
  static const Color paidColor = Color(0xFF10B981);
  static const Color paidLightColor = Color(0xFF6EE7B7);  // More vibrant green
  static const Color paidDarkColor = Color(0xFF065F46);

  /// Upcoming payment color - Yellow/Amber
  static const Color upcomingColor = Color(0xFFF59E0B);
  static const Color upcomingLightColor = Color(0xFFFCD34D);  // More vibrant amber
  static const Color upcomingDarkColor = Color(0xFF92400E);

  /// Overdue payment color - Red
  static const Color overdueColor = Color(0xFFEF4444);
  static const Color overdueLightColor = Color(0xFFFCA5A5);  // More vibrant red
  static const Color overdueDarkColor = Color(0xFF991B1B);

  // =============================================================================
  // NEUTRAL COLORS
  // =============================================================================

  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // =============================================================================
  // LIGHT THEME
  // =============================================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: Colors.white,
        error: overdueColor,
      ),
      scaffoldBackgroundColor: grey50,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: grey900,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: grey900,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: primaryColor),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: grey100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: overdueColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: overdueColor, width: 2),
        ),
        labelStyle: const TextStyle(color: grey600),
        hintStyle: const TextStyle(color: grey400),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: grey400,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: grey100,
        selectedColor: primaryColor.withValues(alpha: 0.2),
        labelStyle: const TextStyle(fontSize: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: grey200,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: grey800,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: grey900,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: grey900,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: grey900,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: grey900,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: grey900,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: grey900,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: grey900,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: grey900,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: grey900,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: grey700,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: grey700,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: grey600,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: grey700,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: grey600,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: grey500,
        ),
      ),
    );
  }

  // =============================================================================
  // DARK THEME
  // =============================================================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: grey900,
        error: overdueColor,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: grey900,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: grey800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: primaryColor),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: grey800,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: grey400),
        hintStyle: const TextStyle(color: grey500),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: grey900,
        selectedItemColor: primaryColor,
        unselectedItemColor: grey500,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: grey800,
        selectedColor: primaryColor.withValues(alpha: 0.3),
        labelStyle: const TextStyle(fontSize: 14, color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: grey700,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: grey700,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: grey300,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: grey300,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: grey400,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: grey300,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: grey400,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: grey500,
        ),
      ),
    );
  }
}
