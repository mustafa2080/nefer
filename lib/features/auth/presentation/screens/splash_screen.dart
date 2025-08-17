import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/providers/providers.dart';

/// Splash Screen with animated Pharaonic logo
/// 
/// Features:
/// - Animated Nefer logo with hieroglyphic elements
/// - Golden particle effects
/// - Smooth transitions to next screen
/// - Auto-navigation based on auth state
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _particleController;
  late AnimationController _textController;
  late AnimationController _fadeController;
  
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
    _navigateAfterDelay();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Fade out controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    ));

    _logoRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    ));

    // Particle animation
    _particleAnimation = CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    );

    // Text animations
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _textSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    // Fade out animation
    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimationSequence() async {
    // Start logo animation
    _logoController.forward();
    
    // Start particle animation after a delay
    await Future.delayed(const Duration(milliseconds: 500));
    _particleController.repeat();
    
    // Start text animation
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
  }

  void _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    
    if (mounted) {
      // Start fade out animation
      _fadeController.forward();
      
      // Wait for fade out to complete
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (mounted) {
        _navigateToNextScreen();
      }
    }
  }

  void _navigateToNextScreen() {
    final authState = ref.read(authStateProvider);
    
    authState.when(
      loading: () => context.go(RouteNames.splash),
      error: (_, __) => context.go(RouteNames.login),
      unauthenticated: () => context.go(RouteNames.login),
      authenticated: (user) {
        if (user.canAccessAdminDashboard()) {
          context.go(RouteNames.admin);
        } else {
          context.go(RouteNames.home);
        }
      },
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadeOutAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeOutAnimation.value,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    NeferColors.lapisBlue,
                    Color(0xFF1E293B),
                    Color(0xFF0F172A),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Background particles
                  _buildParticleBackground(),
                  
                  // Main content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated logo
                        _buildAnimatedLogo(),
                        
                        const SizedBox(height: 40),
                        
                        // App name and tagline
                        _buildAnimatedText(),
                      ],
                    ),
                  ),
                  
                  // Bottom loading indicator
                  _buildLoadingIndicator(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticleBackground() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            animation: _particleAnimation,
            particleCount: 50,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoScaleAnimation, _logoRotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Transform.rotate(
            angle: _logoRotationAnimation.value * 0.1, // Subtle rotation
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: NeferColors.pharaohGradient,
                boxShadow: [
                  BoxShadow(
                    color: NeferColors.pharaohGold.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring with hieroglyphic pattern
                  CustomPaint(
                    painter: HieroglyphicRingPainter(
                      animation: _logoRotationAnimation,
                    ),
                    size: const Size(120, 120),
                  ),
                  
                  // Inner logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 40,
                      color: NeferColors.pharaohGold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: Listenable.merge([_textFadeAnimation, _textSlideAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _textSlideAnimation.value),
          child: Opacity(
            opacity: _textFadeAnimation.value,
            child: Column(
              children: [
                // App name in English
                Text(
                  'Nefer',
                  style: NeferTypography.pharaohTitle.copyWith(
                    color: NeferColors.pharaohGold,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // App name in Arabic
                Text(
                  'نفِر',
                  style: NeferTypography.arabicPharaohTitle.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 32,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Tagline
                Text(
                  'Marketplace of the Pharaohs',
                  style: NeferTypography.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 1.0,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  'سوق الفراعنة',
                  style: NeferTypography.arabicBodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _textFadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _textFadeAnimation.value,
            child: Column(
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(NeferColors.pharaohGold),
                  strokeWidth: 2,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Loading...',
                  style: NeferTypography.bodyMedium.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter for particle background effect
class ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final int particleCount;

  ParticlePainter({
    required this.animation,
    required this.particleCount,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NeferColors.pharaohGold.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < particleCount; i++) {
      final progress = (animation.value + (i / particleCount)) % 1.0;
      final x = (i * 37) % size.width;
      final y = size.height * progress;
      final radius = (math.sin(progress * math.pi) * 3) + 1;
      
      canvas.drawCircle(
        Offset(x.toDouble(), y),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Custom painter for hieroglyphic ring around logo
class HieroglyphicRingPainter extends CustomPainter {
  final Animation<double> animation;

  HieroglyphicRingPainter({
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw rotating hieroglyphic symbols
    const symbols = ['𓋹', '👁️', '🪶', '⭕', '🔺'];
    
    for (int i = 0; i < symbols.length; i++) {
      final angle = (2 * math.pi * i / symbols.length) + (animation.value * 2 * math.pi);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: symbols[i],
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
