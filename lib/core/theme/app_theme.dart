import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: NeferColors.pharaohGold,
        brightness: Brightness.light,
        primary: NeferColors.pharaohGold,
        secondary: NeferColors.turquoiseAccent,
        surface: NeferColors.papyrusWhite,
        background: NeferColors.sandstoneBeige,
        error: NeferColors.error,
      ),
      
      // Typography
      textTheme: _buildTextTheme(Brightness.light),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: NeferColors.papyrusWhite,
        foregroundColor: NeferColors.hieroglyphGray,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: NeferTypography.sectionHeader.copyWith(
          color: NeferColors.hieroglyphGray,
        ),
        iconTheme: const IconThemeData(
          color: NeferColors.hieroglyphGray,
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: NeferColors.papyrusWhite,
        elevation: 2,
        shadowColor: NeferColors.hieroglyphGray.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NeferColors.pharaohGold,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: NeferTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NeferColors.papyrusWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: NeferColors.hieroglyphGray.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: NeferColors.hieroglyphGray.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: NeferColors.pharaohGold,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: NeferColors.error,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: NeferTypography.bodyMedium.copyWith(
          color: NeferColors.hieroglyphGray.withOpacity(0.6),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: NeferColors.papyrusWhite,
        selectedItemColor: NeferColors.pharaohGold,
        unselectedItemColor: NeferColors.hieroglyphGray.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: NeferTypography.caption.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: NeferTypography.caption,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: NeferColors.pharaohGold,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: NeferColors.sandstoneBeige,
        selectedColor: NeferColors.pharaohGold,
        labelStyle: NeferTypography.bodySmall,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: NeferColors.hieroglyphGray.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: NeferColors.darkPharaohGold,
        brightness: Brightness.dark,
        primary: NeferColors.darkPharaohGold,
        secondary: NeferColors.darkTurquoise,
        surface: NeferColors.darkSandstone,
        background: NeferColors.darkPapyrus,
        error: NeferColors.error,
      ),
      
      // Typography
      textTheme: _buildTextTheme(Brightness.dark),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: NeferColors.darkSandstone,
        foregroundColor: NeferColors.sandstoneBeige,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: NeferTypography.sectionHeader.copyWith(
          color: NeferColors.sandstoneBeige,
        ),
        iconTheme: const IconThemeData(
          color: NeferColors.sandstoneBeige,
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: NeferColors.darkSandstone,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NeferColors.darkPharaohGold,
          foregroundColor: NeferColors.darkPapyrus,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: NeferTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NeferColors.darkSandstone,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: NeferColors.sandstoneBeige.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: NeferColors.sandstoneBeige.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: NeferColors.darkPharaohGold,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: NeferColors.error,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: NeferTypography.bodyMedium.copyWith(
          color: NeferColors.sandstoneBeige.withOpacity(0.6),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: NeferColors.darkSandstone,
        selectedItemColor: NeferColors.darkPharaohGold,
        unselectedItemColor: NeferColors.sandstoneBeige.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: NeferTypography.caption.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: NeferTypography.caption,
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: NeferColors.darkPharaohGold,
        foregroundColor: NeferColors.darkPapyrus,
        elevation: 4,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: NeferColors.darkPapyrus,
        selectedColor: NeferColors.darkPharaohGold,
        labelStyle: NeferTypography.bodySmall.copyWith(
          color: NeferColors.sandstoneBeige,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: NeferColors.sandstoneBeige.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.light 
        ? NeferColors.hieroglyphGray 
        : NeferColors.sandstoneBeige;
    
    return TextTheme(
      displayLarge: NeferTypography.pharaohTitle.copyWith(color: baseColor),
      displayMedium: NeferTypography.sectionHeader.copyWith(color: baseColor),
      displaySmall: NeferTypography.sectionHeader.copyWith(
        color: baseColor,
        fontSize: 20,
      ),
      headlineLarge: NeferTypography.sectionHeader.copyWith(color: baseColor),
      headlineMedium: NeferTypography.sectionHeader.copyWith(
        color: baseColor,
        fontSize: 20,
      ),
      headlineSmall: NeferTypography.sectionHeader.copyWith(
        color: baseColor,
        fontSize: 18,
      ),
      titleLarge: NeferTypography.bodyLarge.copyWith(
        color: baseColor,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: NeferTypography.bodyLarge.copyWith(color: baseColor),
      titleSmall: NeferTypography.bodyMedium.copyWith(
        color: baseColor,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: NeferTypography.bodyLarge.copyWith(color: baseColor),
      bodyMedium: NeferTypography.bodyMedium.copyWith(color: baseColor),
      bodySmall: NeferTypography.bodySmall.copyWith(color: baseColor),
      labelLarge: NeferTypography.bodyMedium.copyWith(
        color: baseColor,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: NeferTypography.bodySmall.copyWith(
        color: baseColor,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: NeferTypography.caption.copyWith(color: baseColor),
    );
  }
}
