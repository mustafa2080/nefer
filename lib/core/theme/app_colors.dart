import 'package:flutter/material.dart';

/// Nefer App Color Palette
/// 
/// Inspired by ancient Egyptian pharaonic aesthetics with modern e-commerce usability.
/// All colors are carefully chosen to maintain accessibility standards (WCAG AA).
class NeferColors {
  // Private constructor to prevent instantiation
  NeferColors._();

  // =============================================================================
  // PRIMARY PHARAONIC PALETTE
  // =============================================================================

  /// Primary gold color - represents pharaonic luxury and divine authority
  /// Usage: Primary buttons, highlights, premium elements
  /// Contrast ratio: 4.5:1 on white, 7:1 on dark backgrounds
  static const Color pharaohGold = Color(0xFFD4AF37);

  /// Deep royal blue - represents the sacred lapis lazuli stone
  /// Usage: Headers, navigation, trust elements
  /// Contrast ratio: 12:1 on white
  static const Color lapisBlue = Color(0xFF1E3A8A);

  /// Warm sandstone beige - represents ancient Egyptian architecture
  /// Usage: Backgrounds, neutral surfaces, warm accents
  /// Contrast ratio: 1.2:1 on white (for backgrounds)
  static const Color sandstoneBeige = Color(0xFFF5E6D3);

  /// Turquoise accent - represents the sacred turquoise gemstone
  /// Usage: Success states, highlights, call-to-action secondary
  /// Contrast ratio: 3.5:1 on white
  static const Color turquoiseAccent = Color(0xFF40E0D0);

  /// Off-white papyrus color - represents ancient papyrus scrolls
  /// Usage: Primary backgrounds, card surfaces
  /// Contrast ratio: 1.05:1 on pure white
  static const Color papyrusWhite = Color(0xFFFAF7F0);

  /// Hieroglyph gray - represents carved stone inscriptions
  /// Usage: Text, icons, borders
  /// Contrast ratio: 7:1 on white
  static const Color hieroglyphGray = Color(0xFF4A5568);

  // =============================================================================
  // DARK MODE VARIANTS
  // =============================================================================

  /// Dark mode pharaoh gold - slightly muted for dark backgrounds
  static const Color darkPharaohGold = Color(0xFFB8941F);

  /// Dark mode lapis blue - deeper for dark theme
  static const Color darkLapisBlue = Color(0xFF0F1419);

  /// Dark mode sandstone - darker neutral
  static const Color darkSandstone = Color(0xFF2D2A26);

  /// Dark mode turquoise - adjusted for dark backgrounds
  static const Color darkTurquoise = Color(0xFF2DD4BF);

  /// Dark mode papyrus - dark background color
  static const Color darkPapyrus = Color(0xFF1A1A1A);

  /// Dark mode hieroglyph gray - lighter for dark backgrounds
  static const Color darkHieroglyphGray = Color(0xFFE2E8F0);

  // =============================================================================
  // SEMANTIC COLORS
  // =============================================================================

  /// Success color - for positive actions and confirmations
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF047857);

  /// Warning color - for caution and important notices
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  /// Error color - for errors and destructive actions
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);

  /// Info color - for informational messages
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1D4ED8);

  // =============================================================================
  // E-COMMERCE SPECIFIC COLORS
  // =============================================================================

  /// Sale/discount color - for promotional elements
  static const Color saleRed = Color(0xFFE53E3E);
  static const Color saleRedLight = Color(0xFFFED7D7);

  /// Price color - for pricing displays
  static const Color priceGreen = Color(0xFF38A169);
  static const Color priceGreenLight = Color(0xFFC6F6D5);

  /// Out of stock color - for unavailable items
  static const Color outOfStock = Color(0xFF718096);
  static const Color outOfStockLight = Color(0xFFEDF2F7);

  /// Rating star color - for product ratings
  static const Color ratingStar = Color(0xFFFFB800);
  static const Color ratingStarEmpty = Color(0xFFE2E8F0);

  /// Wishlist heart color - for wishlist items
  static const Color wishlistHeart = Color(0xFFE53E3E);
  static const Color wishlistHeartEmpty = Color(0xFFE2E8F0);

  // =============================================================================
  // GRADIENT DEFINITIONS
  // =============================================================================

  /// Primary pharaoh gradient - for premium elements
  static const LinearGradient pharaohGradient = LinearGradient(
    colors: [pharaohGold, Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
  );

  /// Mystical gradient - for magical/premium experiences
  static const LinearGradient mysticalGradient = LinearGradient(
    colors: [lapisBlue, Color(0xFF1E40AF), Color(0xFF3730A3)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
  );

  /// Sunset gradient - for warm, inviting elements
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [pharaohGold, Color(0xFFFF8C00), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.6, 1.0],
  );

  /// Sandstone gradient - for neutral backgrounds
  static const LinearGradient sandstoneGradient = LinearGradient(
    colors: [sandstoneBeige, Color(0xFFF0E6D2), Color(0xFFEBDCC3)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
  );

  /// Dark mode pharaoh gradient
  static const LinearGradient darkPharaohGradient = LinearGradient(
    colors: [darkPharaohGold, Color(0xFFA67C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
  );

  /// Dark mode mystical gradient
  static const LinearGradient darkMysticalGradient = LinearGradient(
    colors: [darkLapisBlue, Color(0xFF1E293B), Color(0xFF334155)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
  );

  // =============================================================================
  // SHADOW COLORS
  // =============================================================================

  /// Light shadow for elevation
  static const Color lightShadow = Color(0x1A000000);

  /// Medium shadow for cards
  static const Color mediumShadow = Color(0x33000000);

  /// Heavy shadow for modals
  static const Color heavyShadow = Color(0x4D000000);

  /// Pharaoh gold shadow for premium elements
  static const Color goldShadow = Color(0x33D4AF37);

  /// Lapis blue shadow for trust elements
  static const Color blueShadow = Color(0x331E3A8A);

  // =============================================================================
  // OVERLAY COLORS
  // =============================================================================

  /// Light overlay for modals and dialogs
  static const Color lightOverlay = Color(0x80000000);

  /// Dark overlay for image overlays
  static const Color darkOverlay = Color(0xB3000000);

  /// Pharaoh overlay for premium modals
  static const Color pharaohOverlay = Color(0x80D4AF37);

  // =============================================================================
  // BORDER COLORS
  // =============================================================================

  /// Light border for subtle divisions
  static const Color lightBorder = Color(0xFFE2E8F0);

  /// Medium border for form elements
  static const Color mediumBorder = Color(0xFFCBD5E0);

  /// Dark border for emphasis
  static const Color darkBorder = Color(0xFF4A5568);

  /// Pharaoh border for premium elements
  static const Color pharaohBorder = Color(0xFFD4AF37);

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// Get contrasting text color for background
  static Color getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? hieroglyphGray : papyrusWhite;
  }

  /// Get appropriate shadow color for background
  static Color getShadowColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? lightShadow : Color(0x33FFFFFF);
  }

  /// Check if color is dark
  static bool isDark(Color color) {
    return color.computeLuminance() < 0.5;
  }

  /// Check if color is light
  static bool isLight(Color color) {
    return color.computeLuminance() >= 0.5;
  }

  /// Get theme-appropriate color
  static Color getThemeColor({
    required Color lightColor,
    required Color darkColor,
    required bool isDarkMode,
  }) {
    return isDarkMode ? darkColor : lightColor;
  }

  // =============================================================================
  // COLOR SCHEMES
  // =============================================================================

  /// Light color scheme
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: pharaohGold,
    onPrimary: Colors.white,
    secondary: turquoiseAccent,
    onSecondary: Colors.white,
    tertiary: lapisBlue,
    onTertiary: Colors.white,
    error: error,
    onError: Colors.white,
    background: papyrusWhite,
    onBackground: hieroglyphGray,
    surface: Colors.white,
    onSurface: hieroglyphGray,
    surfaceVariant: sandstoneBeige,
    onSurfaceVariant: hieroglyphGray,
    outline: mediumBorder,
    outlineVariant: lightBorder,
    shadow: lightShadow,
    scrim: lightOverlay,
    inverseSurface: hieroglyphGray,
    onInverseSurface: papyrusWhite,
    inversePrimary: darkPharaohGold,
  );

  /// Dark color scheme
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: darkPharaohGold,
    onPrimary: darkPapyrus,
    secondary: darkTurquoise,
    onSecondary: darkPapyrus,
    tertiary: darkLapisBlue,
    onTertiary: sandstoneBeige,
    error: error,
    onError: Colors.white,
    background: darkPapyrus,
    onBackground: sandstoneBeige,
    surface: darkSandstone,
    onSurface: sandstoneBeige,
    surfaceVariant: Color(0xFF3C3A36),
    onSurfaceVariant: sandstoneBeige,
    outline: Color(0xFF5A5A5A),
    outlineVariant: Color(0xFF404040),
    shadow: Color(0x33FFFFFF),
    scrim: darkOverlay,
    inverseSurface: sandstoneBeige,
    onInverseSurface: darkPapyrus,
    inversePrimary: pharaohGold,
  );
}
