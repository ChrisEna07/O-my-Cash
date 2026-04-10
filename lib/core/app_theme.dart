import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color secondaryColor = Color(0xFFF43F5E); // Rose
  static const Color accentColor = Color(0xFF10B981); // Emerald
  
  static ThemeData getTheme(Color primary, Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color background = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color surface = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF334155);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        surface: surface,
        onSurface: textColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: GoogleFonts.outfit(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: secondaryTextColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: (isDark ? GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme) : GoogleFonts.outfitTextTheme(ThemeData.light().textTheme)).copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: textColor),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: textColor),
        bodyLarge: GoogleFonts.outfit(color: textColor),
        bodyMedium: GoogleFonts.outfit(color: textColor),
        bodySmall: GoogleFonts.outfit(color: secondaryTextColor),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? surface : Colors.grey[100],
        labelStyle: TextStyle(color: secondaryTextColor),
        prefixIconColor: secondaryTextColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }
}
