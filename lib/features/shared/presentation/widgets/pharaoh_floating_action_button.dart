import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_colors.dart';

/// Pharaoh-themed floating action button with Egyptian aesthetics
/// 
/// Features:
/// - Golden gradient background
/// - Animated scarab beetle icon
/// - Pulsing glow effect
/// - Badge support for counts
/// - Hieroglyphic-inspired animations
class PharaohFloatingActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final int badgeCount;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;
  final bool mini;

  const PharaohFloatingActionButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.badgeCount = 0,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 56.0,
    this.mini = false,
  }) : super(key: key);

  @override
  State<PharaohFloatingActionButton> createState() => _PharaohFloatingActionButtonState();
}

class _PharaohFloatingActionButtonState extends State<PharaohFloatingActionButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Rotation animation controller
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Scale animation controller for press effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    // Glow animation controller
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Create animations
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _scaleController.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveSize = widget.mini ? 40.0 : widget.size;
    
    return Tooltip(
      message: widget.tooltip ?? '',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Glow effect
          _buildGlowEffect(effectiveSize),
          
          // Main button
          _buildMainButton(theme, effectiveSize),
          
          // Badge
          if (widget.badgeCount > 0)
            _buildBadge(),
        ],
      ),
    );
  }

  Widget _buildGlowEffect(double size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
      builder: (context, child) {
        return Container(
          width: size * _pulseAnimation.value,
          height: size * _pulseAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (widget.backgroundColor ?? NeferColors.pharaohGold)
                    .withOpacity(0.3 * _glowAnimation.value),
                blurRadius: 20 * _glowAnimation.value,
                spreadRadius: 5 * _glowAnimation.value,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainButton(ThemeData theme, double size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              width: size,
              height: size,
              decoration: _buildButtonDecoration(),
              child: _buildButtonContent(),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildButtonDecoration() {
    return BoxDecoration(
      gradient: widget.backgroundColor != null
          ? null
          : NeferColors.pharaohGradient,
      color: widget.backgroundColor,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: NeferColors.goldShadow,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
        if (_isPressed)
          BoxShadow(
            color: NeferColors.pharaohGold.withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
      ],
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  Widget _buildButtonContent() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Background pattern
            _buildBackgroundPattern(),
            
            // Main icon
            Center(
              child: Transform.rotate(
                angle: widget.icon == Icons.favorite 
                    ? _rotationAnimation.value * 0.1 // Subtle rotation for heart
                    : 0,
                child: Icon(
                  widget.icon,
                  size: widget.mini ? 20 : 24,
                  color: widget.foregroundColor ?? Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: ScarabPatternPainter(
              animation: _rotationAnimation,
              color: Colors.white.withOpacity(0.1),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadge() {
    return Positioned(
      right: -2,
      top: -2,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: NeferColors.error,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: NeferColors.error.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                widget.badgeCount > 99 ? '99+' : widget.badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// CUSTOM PAINTER
// =============================================================================

class ScarabPatternPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  ScarabPatternPainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    // Draw rotating scarab-inspired pattern
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(animation.value);

    // Draw scarab body
    final bodyPath = Path();
    bodyPath.addOval(Rect.fromCenter(
      center: Offset.zero,
      width: radius * 0.8,
      height: radius * 1.2,
    ));

    // Draw scarab wings
    final leftWingPath = Path();
    leftWingPath.addOval(Rect.fromCenter(
      center: Offset(-radius * 0.3, 0),
      width: radius * 0.4,
      height: radius * 0.8,
    ));

    final rightWingPath = Path();
    rightWingPath.addOval(Rect.fromCenter(
      center: Offset(radius * 0.3, 0),
      width: radius * 0.4,
      height: radius * 0.8,
    ));

    // Draw the pattern
    canvas.drawPath(bodyPath, paint);
    canvas.drawPath(leftWingPath, paint);
    canvas.drawPath(rightWingPath, paint);

    // Draw decorative lines
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi * 2) / 6;
      final startX = math.cos(angle) * radius * 0.2;
      final startY = math.sin(angle) * radius * 0.2;
      final endX = math.cos(angle) * radius * 0.4;
      final endY = math.sin(angle) * radius * 0.4;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
