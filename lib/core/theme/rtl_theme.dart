import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// RTL Theme Support for Nefer App
/// 
/// Provides comprehensive right-to-left language support for Arabic users,
/// including proper text direction, layout mirroring, and cultural adaptations.
class RTLTheme {
  // Private constructor to prevent instantiation
  RTLTheme._();

  // =============================================================================
  // THEME BUILDERS
  // =============================================================================

  /// Get RTL-adapted theme based on locale
  static ThemeData getRTLTheme(ThemeData baseTheme, Locale locale) {
    final isRTL = _isRTLLocale(locale);
    
    if (isRTL) {
      return _buildRTLTheme(baseTheme, locale);
    }
    
    return baseTheme;
  }

  /// Build RTL-specific theme adaptations
  static ThemeData _buildRTLTheme(ThemeData baseTheme, Locale locale) {
    return baseTheme.copyWith(
      // Text theme with Arabic fonts
      textTheme: _buildRTLTextTheme(baseTheme.textTheme, locale),
      
      // Input decoration with RTL adjustments
      inputDecorationTheme: _buildRTLInputTheme(baseTheme.inputDecorationTheme),
      
      // App bar theme with RTL considerations
      appBarTheme: _buildRTLAppBarTheme(baseTheme.appBarTheme),
      
      // Card theme with RTL spacing
      cardTheme: _buildRTLCardTheme(baseTheme.cardTheme),
      
      // List tile theme with RTL content padding
      listTileTheme: _buildRTLListTileTheme(baseTheme.listTileTheme),
      
      // Drawer theme with RTL positioning
      drawerTheme: _buildRTLDrawerTheme(baseTheme.drawerTheme),
      
      // Navigation bar theme with RTL icon positioning
      bottomNavigationBarTheme: _buildRTLBottomNavTheme(
        baseTheme.bottomNavigationBarTheme,
      ),
      
      // Tab bar theme with RTL adjustments
      tabBarTheme: _buildRTLTabBarTheme(baseTheme.tabBarTheme),
      
      // Chip theme with RTL padding
      chipTheme: _buildRTLChipTheme(baseTheme.chipTheme),
      
      // Dialog theme with RTL content alignment
      dialogTheme: _buildRTLDialogTheme(baseTheme.dialogTheme),
    );
  }

  // =============================================================================
  // TEXT THEME BUILDERS
  // =============================================================================

  static TextTheme _buildRTLTextTheme(TextTheme baseTheme, Locale locale) {
    if (locale.languageCode == 'ar') {
      return NeferTypography.buildArabicTextTheme().copyWith(
        // Apply base theme colors
        displayLarge: baseTheme.displayLarge?.copyWith(
          fontFamily: NeferTypography.arabicFont,
          height: 1.6,
        ),
        displayMedium: baseTheme.displayMedium?.copyWith(
          fontFamily: NeferTypography.arabicFont,
          height: 1.5,
        ),
        displaySmall: baseTheme.displaySmall?.copyWith(
          fontFamily: NeferTypography.arabicFont,
          height: 1.5,
        ),
        headlineLarge: baseTheme.headlineLarge?.copyWith(
          fontFamily: NeferTypography.arabicFont,
          height: 1.5,
        ),
        headlineMedium: baseTheme.headlineMedium?.copyWith(
          fontFamily: NeferTypography.arabicFont,
          height: 1.5,
        ),
        headlineSmall: baseTheme.headlineSmall?.copyWith(
          fontFamily: NeferTypography.arabicFont,
          height: 1.6,
        ),
        titleLarge: baseTheme.titleLarge?.copyWith(
          fontFamily: NeferTypography.arabicFont,
          height: 1.6,
        ),
        titleMedium: baseTheme.titleMedium?.copyWith(
          fontFamily: NeferTypography.arabicFont,
          height: 1.7,
        ),
        titleSmall: baseTheme.titleSmall?.copyWith(
          fontFamily: NeferTypography.arabicFont,
          height: 1.7,
        ),
        bodyLarge: baseTheme.bodyLarge?.copyWith(
          fontFamily: NeferTypography.arabicFont,
          height: 1.8,
        ),
        bodyMedium: baseTheme.bodyMedium?.copyWith(
          fontFamily: NeferTypography.arabicFont,
          height: 1.7,
        ),
        bodySmall: baseTheme.bodySmall?.copyWith(
          fontFamily: NeferTypography.arabicFont,
          height: 1.6,
        ),
        labelLarge: baseTheme.labelLarge?.copyWith(
          fontFamily: NeferTypography.arabicFont,
          height: 1.7,
        ),
        labelMedium: baseTheme.labelMedium?.copyWith(
          fontFamily: NeferTypography.arabicFont,
          height: 1.6,
        ),
        labelSmall: baseTheme.labelSmall?.copyWith(
          fontFamily: NeferTypography.arabicFont,
          height: 1.6,
        ),
      );
    }
    
    return baseTheme;
  }

  // =============================================================================
  // COMPONENT THEME BUILDERS
  // =============================================================================

  static InputDecorationTheme _buildRTLInputTheme(
    InputDecorationTheme? baseTheme,
  ) {
    return (baseTheme ?? const InputDecorationTheme()).copyWith(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      // RTL-specific adjustments for text alignment
      alignLabelWithHint: true,
    );
  }

  static AppBarTheme _buildRTLAppBarTheme(AppBarTheme? baseTheme) {
    return (baseTheme ?? const AppBarTheme()).copyWith(
      centerTitle: true, // Center title works well for both LTR and RTL
      titleSpacing: 0, // Let the system handle spacing
    );
  }

  static CardTheme _buildRTLCardTheme(CardTheme? baseTheme) {
    return (baseTheme ?? const CardTheme()).copyWith(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
    );
  }

  static ListTileTheme _buildRTLListTileTheme(ListTileTheme? baseTheme) {
    return (baseTheme ?? const ListTileTheme()).copyWith(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
    );
  }

  static DrawerThemeData _buildRTLDrawerTheme(DrawerThemeData? baseTheme) {
    return (baseTheme ?? const DrawerThemeData()).copyWith(
      // RTL drawer positioning is handled automatically by Flutter
    );
  }

  static BottomNavigationBarThemeData _buildRTLBottomNavTheme(
    BottomNavigationBarThemeData? baseTheme,
  ) {
    return (baseTheme ?? const BottomNavigationBarThemeData()).copyWith(
      // Bottom navigation works the same for RTL
      type: BottomNavigationBarType.fixed,
    );
  }

  static TabBarTheme _buildRTLTabBarTheme(TabBarTheme? baseTheme) {
    return (baseTheme ?? const TabBarTheme()).copyWith(
      // Tab bar adjustments for RTL
      labelPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  static ChipThemeData _buildRTLChipTheme(ChipThemeData? baseTheme) {
    return (baseTheme ?? const ChipThemeData()).copyWith(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  static DialogTheme _buildRTLDialogTheme(DialogTheme? baseTheme) {
    return (baseTheme ?? const DialogTheme()).copyWith(
      contentTextStyle: const TextStyle(
        fontFamily: NeferTypography.arabicFont,
      ),
      titleTextStyle: const TextStyle(
        fontFamily: NeferTypography.arabicFont,
      ),
    );
  }

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Check if locale is RTL
  static bool _isRTLLocale(Locale locale) {
    return locale.languageCode == 'ar' ||
           locale.languageCode == 'he' ||
           locale.languageCode == 'fa' ||
           locale.languageCode == 'ur';
  }

  /// Get text direction for locale
  static TextDirection getTextDirection(Locale locale) {
    return _isRTLLocale(locale) ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Get directional padding based on context
  static EdgeInsets getDirectionalPadding({
    required BuildContext context,
    double start = 0,
    double top = 0,
    double end = 0,
    double bottom = 0,
  }) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return EdgeInsets.only(
      left: isRTL ? end : start,
      top: top,
      right: isRTL ? start : end,
      bottom: bottom,
    );
  }

  /// Get directional margin based on context
  static EdgeInsets getDirectionalMargin({
    required BuildContext context,
    double start = 0,
    double top = 0,
    double end = 0,
    double bottom = 0,
  }) {
    return getDirectionalPadding(
      context: context,
      start: start,
      top: top,
      end: end,
      bottom: bottom,
    );
  }

  /// Get directional alignment
  static Alignment getDirectionalAlignment({
    required BuildContext context,
    required Alignment ltrAlignment,
    required Alignment rtlAlignment,
  }) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return isRTL ? rtlAlignment : ltrAlignment;
  }

  /// Get directional text align
  static TextAlign getDirectionalTextAlign({
    required BuildContext context,
    TextAlign? ltrAlign,
    TextAlign? rtlAlign,
  }) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    if (isRTL && rtlAlign != null) return rtlAlign;
    if (!isRTL && ltrAlign != null) return ltrAlign;
    
    // Default behavior
    return isRTL ? TextAlign.right : TextAlign.left;
  }

  /// Get directional icon based on context
  static IconData getDirectionalIcon({
    required BuildContext context,
    required IconData ltrIcon,
    required IconData rtlIcon,
  }) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return isRTL ? rtlIcon : ltrIcon;
  }

  /// Mirror widget for RTL if needed
  static Widget mirrorForRTL({
    required BuildContext context,
    required Widget child,
    bool shouldMirror = true,
  }) {
    if (!shouldMirror) return child;
    
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    if (isRTL) {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
        child: child,
      );
    }
    
    return child;
  }

  /// Get culturally appropriate colors for RTL
  static Color getCulturalColor({
    required BuildContext context,
    required Color defaultColor,
    Color? arabicColor,
  }) {
    final locale = Localizations.localeOf(context);
    
    if (locale.languageCode == 'ar' && arabicColor != null) {
      return arabicColor;
    }
    
    return defaultColor;
  }

  /// Get appropriate font size for Arabic text
  static double getArabicFontSize(double baseFontSize) {
    // Arabic text often needs slightly larger font sizes for readability
    return baseFontSize * 1.1;
  }

  /// Get appropriate line height for Arabic text
  static double getArabicLineHeight(double baseLineHeight) {
    // Arabic text needs more line height due to diacritics
    return baseLineHeight * 1.2;
  }

  // =============================================================================
  // RTL-AWARE WIDGETS
  // =============================================================================

  /// Create RTL-aware positioned widget
  static Widget positioned({
    required BuildContext context,
    required Widget child,
    double? start,
    double? end,
    double? top,
    double? bottom,
    double? width,
    double? height,
  }) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    return Positioned(
      left: isRTL ? end : start,
      right: isRTL ? start : end,
      top: top,
      bottom: bottom,
      width: width,
      height: height,
      child: child,
    );
  }

  /// Create RTL-aware row with proper spacing
  static Widget row({
    required BuildContext context,
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    // Reverse children order for RTL
    final orderedChildren = isRTL ? children.reversed.toList() : children;
    
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: orderedChildren,
    );
  }

  /// Create RTL-aware wrap with proper direction
  static Widget wrap({
    required BuildContext context,
    required List<Widget> children,
    WrapAlignment alignment = WrapAlignment.start,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    double spacing = 0.0,
    double runSpacing = 0.0,
  }) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    return Wrap(
      direction: Axis.horizontal,
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      spacing: spacing,
      runSpacing: runSpacing,
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      children: children,
    );
  }
}
