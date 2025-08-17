import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Pharaoh-themed animated app bar with Egyptian motifs
/// 
/// Features:
/// - Animated wings of Horus expansion
/// - Hieroglyphic background patterns
/// - Golden accent animations
/// - Notification badges
/// - Search integration
class PharaohAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showSearchButton;
  final bool showNotificationButton;
  final int notificationCount;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onBackTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool expanded;
  final Widget? flexibleSpace;
  final List<Widget>? actions;

  const PharaohAppBar({
    Key? key,
    required this.title,
    this.showBackButton = false,
    this.showSearchButton = true,
    this.showNotificationButton = true,
    this.notificationCount = 0,
    this.onSearchTap,
    this.onNotificationTap,
    this.onBackTap,
    this.backgroundColor,
    this.foregroundColor,
    this.expanded = false,
    this.flexibleSpace,
    this.actions,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(expanded ? 200 : kToolbarHeight);

  @override
  State<PharaohAppBar> createState() => _PharaohAppBarState();
}

class _PharaohAppBarState extends State<PharaohAppBar>
    with TickerProviderStateMixin {
  late AnimationController _wingsController;
  late AnimationController _shimmerController;
  late AnimationController _titleController;
  
  late Animation<double> _wingsAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _titleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Wings animation controller
    _wingsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Shimmer animation controller
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Title animation controller
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Wings animation
    _wingsAnimation = CurvedAnimation(
      parent: _wingsController,
      curve: Curves.easeOutCubic,
    );

    // Shimmer animation
    _shimmerAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );

    // Title animation
    _titleAnimation = CurvedAnimation(
      parent: _titleController,
      curve: Curves.elasticOut,
    );
  }

  void _startAnimations() {
    _wingsController.forward();
    _titleController.forward();
    _shimmerController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _wingsController.dispose();
    _shimmerController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    return AppBar(
      backgroundColor: widget.backgroundColor ?? theme.colorScheme.surface,
      foregroundColor: widget.foregroundColor ?? theme.colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      
      // Leading widget
      leading: widget.showBackButton
          ? _buildBackButton(context, isRTL)
          : null,
      
      // Title with animations
      title: _buildAnimatedTitle(context),
      
      // Actions
      actions: _buildActions(context, isRTL),
      
      // Flexible space for expanded mode
      flexibleSpace: widget.expanded
          ? _buildFlexibleSpace(context)
          : _buildSimpleBackground(context),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isRTL) {
    return IconButton(
      onPressed: widget.onBackTap ?? () => Navigator.of(context).pop(),
      icon: AnimatedBuilder(
        animation: _titleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _titleAnimation.value,
            child: Icon(
              isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
              color: widget.foregroundColor ?? 
                     Theme.of(context).colorScheme.onSurface,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedTitle(BuildContext context) {
    return AnimatedBuilder(
      animation: _titleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _titleAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _titleAnimation.value)),
            child: Opacity(
              opacity: _titleAnimation.value,
              child: Text(
                widget.title,
                style: NeferTypography.sectionHeader.copyWith(
                  color: widget.foregroundColor ?? 
                         Theme.of(context).colorScheme.onSurface,
                  fontSize: widget.expanded ? 28 : 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildActions(BuildContext context, bool isRTL) {
    final actions = <Widget>[];
    
    if (widget.showSearchButton) {
      actions.add(_buildSearchButton(context));
    }
    
    if (widget.showNotificationButton) {
      actions.add(_buildNotificationButton(context));
    }
    
    // Add custom actions
    if (widget.actions != null) {
      actions.addAll(widget.actions!);
    }
    
    return actions;
  }

  Widget _buildSearchButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _titleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _titleAnimation.value,
          child: IconButton(
            onPressed: widget.onSearchTap,
            icon: const Icon(Icons.search),
            tooltip: 'Search',
          ),
        );
      },
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _titleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _titleAnimation.value,
          child: Stack(
            children: [
              IconButton(
                onPressed: widget.onNotificationTap,
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifications',
              ),
              if (widget.notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: _buildNotificationBadge(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationBadge() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: NeferColors.error,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: NeferColors.error.withOpacity(0.3 + 0.2 * _shimmerAnimation.value),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          constraints: const BoxConstraints(
            minWidth: 16,
            minHeight: 16,
          ),
          child: Text(
            widget.notificationCount > 99 ? '99+' : widget.notificationCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildFlexibleSpace(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: NeferColors.pharaohGradient,
        boxShadow: [
          BoxShadow(
            color: NeferColors.goldShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          _buildHieroglyphicPattern(),
          
          // Wings animation
          _buildWingsAnimation(),
          
          // Shimmer effect
          _buildShimmerEffect(),
          
          // Custom flexible space content
          if (widget.flexibleSpace != null)
            Positioned.fill(child: widget.flexibleSpace!),
        ],
      ),
    );
  }

  Widget _buildSimpleBackground(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: NeferColors.lightShadow.withOpacity(0.1 + 0.05 * _shimmerAnimation.value),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHieroglyphicPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: HieroglyphicPatternPainter(
          animation: _shimmerAnimation,
        ),
      ),
    );
  }

  Widget _buildWingsAnimation() {
    return AnimatedBuilder(
      animation: _wingsAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: CustomPaint(
            painter: WingsOfHorusPainter(
              animation: _wingsAnimation,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.1 * _shimmerAnimation.value),
                  Colors.white.withOpacity(0.0),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}

// =============================================================================
// CUSTOM PAINTERS
// =============================================================================

class HieroglyphicPatternPainter extends CustomPainter {
  final Animation<double> animation;

  HieroglyphicPatternPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05 + 0.02 * animation.value)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw simple hieroglyphic-inspired patterns
    final spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        _drawHieroglyphicSymbol(canvas, paint, Offset(x, y));
      }
    }
  }

  void _drawHieroglyphicSymbol(Canvas canvas, Paint paint, Offset center) {
    // Draw a simple ankh-inspired symbol
    final path = Path();
    path.addOval(Rect.fromCenter(center: center, width: 8, height: 8));
    path.moveTo(center.dx, center.dy + 4);
    path.lineTo(center.dx, center.dy + 12);
    path.moveTo(center.dx - 4, center.dy + 8);
    path.lineTo(center.dx + 4, center.dy + 8);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class WingsOfHorusPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  WingsOfHorusPainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final wingSpan = size.width * 0.6 * animation.value;
    final wingHeight = size.height * 0.3 * animation.value;

    // Draw left wing
    final leftWingPath = Path();
    leftWingPath.moveTo(center.dx, center.dy);
    leftWingPath.quadraticBezierTo(
      center.dx - wingSpan / 2,
      center.dy - wingHeight,
      center.dx - wingSpan,
      center.dy,
    );
    leftWingPath.quadraticBezierTo(
      center.dx - wingSpan / 2,
      center.dy + wingHeight / 2,
      center.dx,
      center.dy,
    );

    // Draw right wing
    final rightWingPath = Path();
    rightWingPath.moveTo(center.dx, center.dy);
    rightWingPath.quadraticBezierTo(
      center.dx + wingSpan / 2,
      center.dy - wingHeight,
      center.dx + wingSpan,
      center.dy,
    );
    rightWingPath.quadraticBezierTo(
      center.dx + wingSpan / 2,
      center.dy + wingHeight / 2,
      center.dx,
      center.dy,
    );

    canvas.drawPath(leftWingPath, paint);
    canvas.drawPath(rightWingPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
