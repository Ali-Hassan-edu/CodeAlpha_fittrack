import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Kinetic Sanctuary Color Tokens ───────────────────────────────────────────
class AppColors {
  // Primary — Vibrant Mint
  static const primary = Color(0xFF006854);
  static const onPrimary = Color(0xFFC4FFEB);
  static const primaryContainer = Color(0xFF33F5CB);
  static const onPrimaryContainer = Color(0xFF005746);
  static const primaryFixed = Color(0xFF33F5CB);
  static const primaryFixedDim = Color(0xFF06E6BD);
  static const primaryDim = Color(0xFF005B49);

  // Secondary — Electric Blue
  static const secondary = Color(0xFF0055C4);
  static const onSecondary = Color(0xFFF0F2FF);
  static const secondaryContainer = Color(0xFFC0D1FF);
  static const onSecondaryContainer = Color(0xFF00429C);
  static const secondaryFixed = Color(0xFFC0D1FF);
  static const secondaryFixedDim = Color(0xFFACC3FF);

  // Tertiary — Warm Amber (High Intensity / PRs)
  static const tertiary = Color(0xFF9B3F00);
  static const onTertiary = Color(0xFFFFF0EA);
  static const tertiaryContainer = Color(0xFFFF955E);
  static const onTertiaryContainer = Color(0xFF562000);

  // Surface hierarchy — Frosted Teal
  static const surface = Color(0xFFD5FFF7);
  static const surfaceBright = Color(0xFFD5FFF7);
  static const surfaceDim = Color(0xFF8AE4D7);
  static const surfaceVariant = Color(0xFF98ECDF);
  static const surfaceContainer = Color(0xFFAEF6EA);
  static const surfaceContainerHigh = Color(0xFFA3F1E4);
  static const surfaceContainerHighest = Color(0xFF98ECDF);
  static const surfaceContainerLow = Color(0xFFBBFEF2);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);

  // On-surface
  static const onSurface = Color(0xFF003530);
  static const onSurfaceVariant = Color(0xFF2B655D);
  static const onBackground = Color(0xFF003530);

  // Outline
  static const outline = Color(0xFF488178);
  static const outlineVariant = Color(0xFF7EB8AE);

  // Error
  static const error = Color(0xFFB31B25);
  static const onError = Color(0xFFFFEFEE);
  static const errorContainer = Color(0xFFFB5151);
  static const onErrorContainer = Color(0xFF570008);

  // Misc
  static const background = Color(0xFFD5FFF7);
  static const inverseSurface = Color(0xFF00110F);
  static const inverseOnSurface = Color(0xFF6EA79E);
  static const inversePrimary = Color(0xFF33F5CB);

  // Gradient — Kinetic Signature
  static const kineticGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
    stops: [0.0, 1.0],
  );
}

// ─── Theme Builder ─────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        shadow: Colors.transparent,
        scrim: Colors.transparent,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        inversePrimary: AppColors.inversePrimary,
        surfaceTint: AppColors.primary,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.onSurface),
        titleTextStyle: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          color: AppColors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(100),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.outlineVariant,
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.onSurfaceVariant,
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
          textStyle: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.secondaryFixed,
        selectedColor: AppColors.secondary,
        labelStyle: const TextStyle(
          fontFamily: 'Lexend',
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.outlineVariant,
      ),
      dividerTheme: const DividerThemeData(color: Colors.transparent),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      // Display — Plus Jakarta Sans
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 57, fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 45, fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.onSurface,
      ),
      // Headline — Plus Jakarta Sans
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.onSurface,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.onSurface,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.onSurface,
      ),
      // Title
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurface,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface,
      ),
      // Body — Inter
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.onSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant,
      ),
      // Label — Lexend
      labelLarge: GoogleFonts.lexend(
        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onSurface,
      ),
      labelMedium: GoogleFonts.lexend(
        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface,
      ),
      labelSmall: GoogleFonts.lexend(
        fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant,
        letterSpacing: 1.2,
      ),
    );
  }
}
