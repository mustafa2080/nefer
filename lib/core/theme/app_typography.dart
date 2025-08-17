import 'package:flutter/material.dart';

/// Nefer App Typography System
/// 
/// Combines elegant serif fonts for display text (Pharaonic feel) with modern
/// sans-serif fonts for body text (readability). Includes full Arabic support.
class NeferTypography {
  // Private constructor to prevent instantiation
  NeferTypography._();

  // =============================================================================
  // FONT FAMILIES
  // =============================================================================

  /// Display font for headers and titles - elegant serif with pharaonic feel
  static const String displayFont = 'Cinzel';

  /// Body font for content - modern sans-serif for readability
  static const String bodyFont = 'Inter';

  /// Arabic font for RTL text - traditional Arabic typography
  static const String arabicFont = 'Amiri';

  /// Monospace font for code and numbers
  static const String monospaceFont = 'Courier New';

  // =============================================================================
  // FONT WEIGHTS
  // =============================================================================

  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // =============================================================================
  // DISPLAY TEXT STYLES (Pharaonic Headers)
  // =============================================================================

  /// Pharaoh title - largest display text for app branding
  static const TextStyle pharaohTitle = TextStyle(
    fontFamily: displayFont,
    fontSize: 32,
    fontWeight: bold,
    letterSpacing: 1.2,
    height: 1.2,
  );

  /// Section header - for major section titles
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: displayFont,
    fontSize: 24,
    fontWeight: semiBold,
    letterSpacing: 0.8,
    height: 1.3,
  );

  /// Subsection header - for subsection titles
  static const TextStyle subsectionHeader = TextStyle(
    fontFamily: displayFont,
    fontSize: 20,
    fontWeight: semiBold,
    letterSpacing: 0.6,
    height: 1.3,
  );

  /// Card title - for card headers and product names
  static const TextStyle cardTitle = TextStyle(
    fontFamily: displayFont,
    fontSize: 18,
    fontWeight: semiBold,
    letterSpacing: 0.4,
    height: 1.3,
  );

  /// Small title - for small headers and labels
  static const TextStyle smallTitle = TextStyle(
    fontFamily: displayFont,
    fontSize: 16,
    fontWeight: semiBold,
    letterSpacing: 0.2,
    height: 1.3,
  );

  // =============================================================================
  // BODY TEXT STYLES (Modern Sans-Serif)
  // =============================================================================

  /// Large body text - for important content
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.1,
  );

  /// Medium body text - standard content text
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: regular,
    height: 1.4,
    letterSpacing: 0.1,
  );

  /// Small body text - for secondary content
  static const TextStyle bodySmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: regular,
    height: 1.4,
    letterSpacing: 0.2,
  );

  /// Caption text - for captions and metadata
  static const TextStyle caption = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: regular,
    letterSpacing: 0.4,
    height: 1.3,
  );

  /// Overline text - for overlines and small labels
  static const TextStyle overline = TextStyle(
    fontFamily: bodyFont,
    fontSize: 10,
    fontWeight: medium,
    letterSpacing: 1.5,
    height: 1.6,
  );

  // =============================================================================
  // BUTTON TEXT STYLES
  // =============================================================================

  /// Large button text
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: semiBold,
    letterSpacing: 0.5,
    height: 1.2,
  );

  /// Medium button text
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: semiBold,
    letterSpacing: 0.5,
    height: 1.2,
  );

  /// Small button text
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: semiBold,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // =============================================================================
  // SPECIAL PURPOSE STYLES
  // =============================================================================

  /// Price text - for pricing displays
  static const TextStyle price = TextStyle(
    fontFamily: bodyFont,
    fontSize: 18,
    fontWeight: bold,
    letterSpacing: 0.2,
    height: 1.2,
  );

  /// Large price text - for prominent pricing
  static const TextStyle priceLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 24,
    fontWeight: bold,
    letterSpacing: 0.2,
    height: 1.2,
  );

  /// Discount text - for sale prices
  static const TextStyle discount = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.2,
    height: 1.2,
    decoration: TextDecoration.lineThrough,
  );

  /// Rating text - for product ratings
  static const TextStyle rating = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: medium,
    letterSpacing: 0.1,
    height: 1.2,
  );

  /// Badge text - for badges and chips
  static const TextStyle badge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: semiBold,
    letterSpacing: 0.3,
    height: 1.2,
  );

  /// Code text - for monospace content
  static const TextStyle code = TextStyle(
    fontFamily: monospaceFont,
    fontSize: 14,
    fontWeight: regular,
    letterSpacing: 0.0,
    height: 1.4,
  );

  // =============================================================================
  // ARABIC TEXT STYLES
  // =============================================================================

  /// Arabic pharaoh title
  static const TextStyle arabicPharaohTitle = TextStyle(
    fontFamily: arabicFont,
    fontSize: 32,
    fontWeight: bold,
    height: 1.6,
  );

  /// Arabic section header
  static const TextStyle arabicSectionHeader = TextStyle(
    fontFamily: arabicFont,
    fontSize: 24,
    fontWeight: bold,
    height: 1.5,
  );

  /// Arabic body large
  static const TextStyle arabicBodyLarge = TextStyle(
    fontFamily: arabicFont,
    fontSize: 16,
    fontWeight: regular,
    height: 1.8,
  );

  /// Arabic body medium
  static const TextStyle arabicBodyMedium = TextStyle(
    fontFamily: arabicFont,
    fontSize: 14,
    fontWeight: regular,
    height: 1.7,
  );

  /// Arabic body small
  static const TextStyle arabicBodySmall = TextStyle(
    fontFamily: arabicFont,
    fontSize: 12,
    fontWeight: regular,
    height: 1.6,
  );

  // =============================================================================
  // RESPONSIVE TEXT STYLES
  // =============================================================================

  /// Get responsive text style based on screen size
  static TextStyle getResponsiveStyle({
    required TextStyle baseStyle,
    required double screenWidth,
  }) {
    double scaleFactor = 1.0;
    
    if (screenWidth < 360) {
      scaleFactor = 0.9; // Small phones
    } else if (screenWidth > 600) {
      scaleFactor = 1.1; // Tablets
    }
    
    return baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 14) * scaleFactor,
    );
  }

  /// Get text style for current locale
  static TextStyle getLocalizedStyle({
    required TextStyle englishStyle,
    required TextStyle arabicStyle,
    required String languageCode,
  }) {
    return languageCode == 'ar' ? arabicStyle : englishStyle;
  }

  // =============================================================================
  // TEXT THEME BUILDERS
  // =============================================================================

  /// Build complete text theme for light mode
  static TextTheme buildLightTextTheme() {
    return const TextTheme(
      displayLarge: pharaohTitle,
      displayMedium: sectionHeader,
      displaySmall: subsectionHeader,
      headlineLarge: sectionHeader,
      headlineMedium: subsectionHeader,
      headlineSmall: cardTitle,
      titleLarge: cardTitle,
      titleMedium: smallTitle,
      titleSmall: bodyLarge,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: buttonMedium,
      labelMedium: buttonSmall,
      labelSmall: caption,
    );
  }

  /// Build complete text theme for dark mode
  static TextTheme buildDarkTextTheme() {
    return buildLightTextTheme(); // Same styles, colors handled by theme
  }

  /// Build Arabic text theme
  static TextTheme buildArabicTextTheme() {
    return const TextTheme(
      displayLarge: arabicPharaohTitle,
      displayMedium: arabicSectionHeader,
      displaySmall: arabicSectionHeader,
      headlineLarge: arabicSectionHeader,
      headlineMedium: arabicSectionHeader,
      headlineSmall: arabicBodyLarge,
      titleLarge: arabicBodyLarge,
      titleMedium: arabicBodyMedium,
      titleSmall: arabicBodyMedium,
      bodyLarge: arabicBodyLarge,
      bodyMedium: arabicBodyMedium,
      bodySmall: arabicBodySmall,
      labelLarge: arabicBodyMedium,
      labelMedium: arabicBodySmall,
      labelSmall: arabicBodySmall,
    );
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Apply color to text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Apply weight to text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Apply size to text style
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Apply decoration to text style
  static TextStyle withDecoration(TextStyle style, TextDecoration decoration) {
    return style.copyWith(decoration: decoration);
  }

  /// Apply letter spacing to text style
  static TextStyle withLetterSpacing(TextStyle style, double letterSpacing) {
    return style.copyWith(letterSpacing: letterSpacing);
  }

  /// Apply line height to text style
  static TextStyle withHeight(TextStyle style, double height) {
    return style.copyWith(height: height);
  }

  /// Create emphasized version of text style
  static TextStyle emphasized(TextStyle style) {
    return style.copyWith(
      fontWeight: FontWeight.values[
        (style.fontWeight?.index ?? FontWeight.normal.index) + 1
      ],
    );
  }

  /// Create de-emphasized version of text style
  static TextStyle deEmphasized(TextStyle style) {
    return style.copyWith(
      fontWeight: FontWeight.values[
        ((style.fontWeight?.index ?? FontWeight.normal.index) - 1)
            .clamp(0, FontWeight.values.length - 1)
      ],
    );
  }

  // =============================================================================
  // ACCESSIBILITY HELPERS
  // =============================================================================

  /// Get minimum font size for accessibility
  static double getMinimumFontSize() {
    return 12.0; // WCAG AA minimum
  }

  /// Get maximum font size for readability
  static double getMaximumFontSize() {
    return 48.0; // Practical maximum
  }

  /// Ensure font size is within accessible range
  static double clampFontSize(double fontSize) {
    return fontSize.clamp(getMinimumFontSize(), getMaximumFontSize());
  }

  /// Get accessible text style with proper contrast
  static TextStyle getAccessibleStyle({
    required TextStyle baseStyle,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return baseStyle.copyWith(
      color: textColor,
      fontSize: clampFontSize(baseStyle.fontSize ?? 14),
    );
  }
}
