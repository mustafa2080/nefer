import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../screens/main_navigation_screen.dart';

/// Pharaoh-themed bottom navigation bar with Egyptian aesthetics
/// 
/// Features:
/// - Golden accent animations
/// - Hieroglyphic-inspired design elements
/// - Smooth tab transitions
/// - Cart badge support
/// - RTL support
class PharaohBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavItem> items;
  final int cartItemCount;

  const PharaohBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.cartItemCount = 0,
  }) : super(key: key);

  @override
  State<PharaohBottomNavBar> createState() => _PharaohBottomNavBarState();
}

class _PharaohBottomNavBarState extends State<PharaohBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _selectionController;
  late AnimationController _shimmerController;
  late List<AnimationController> _iconControllers;
  
  late Animation<double> _selectionAnimation;
  late Animation<double> _shimmerAnimation;
  late List<Animation<double>> _iconAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Selection indicator animation
    _selectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Shimmer effect animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Icon animations for each tab
    _iconControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    // Create animations
    _selectionAnimation = CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeInOutCubic,
    );

    _shimmerAnimation = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );

    _iconAnimations = _iconControllers
        .map((controller) => CurvedAnimation(
              parent: controller,
              curve: Curves.elasticOut,
            ))
        .toList();
  }

  void _startAnimations() {
    _selectionController.forward();
    _shimmerController.repeat(reverse: true);
    
    // Animate current icon
    if (widget.currentIndex < _iconControllers.length) {
      _iconControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(PharaohBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animateTabChange(oldWidget.currentIndex, widget.currentIndex);
    }
  }

  void _animateTabChange(int oldIndex, int newIndex) {
    // Reset old icon
    if (oldIndex < _iconControllers.length) {
      _iconControllers[oldIndex].reverse();
    }
    
    // Animate new icon
    if (newIndex < _iconControllers.length) {
      _iconControllers[newIndex].forward();
    }
    
    // Animate selection indicator
    _selectionController.reset();
    _selectionController.forward();
  }

  @override
  void dispose() {
    _selectionController.dispose();
    _shimmerController.dispose();
    for (final controller in _iconControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    
    return Container(
      decoration: _buildContainerDecoration(theme),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Stack(
            children: [
              // Background pattern
              _buildBackgroundPattern(),
              
              // Selection indicator
              _buildSelectionIndicator(isRTL),
              
              // Navigation items
              _buildNavigationItems(theme, isRTL),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildContainerDecoration(ThemeData theme) {
    return BoxDecoration(
      color: theme.colorScheme.surface,
      boxShadow: [
        BoxShadow(
          color: NeferColors.lightShadow,
          blurRadius: 8,
          offset: const Offset(0, -2),
        ),
        BoxShadow(
          color: NeferColors.goldShadow,
          blurRadius: 4,
          offset: const Offset(0, -1),
        ),
      ],
      border: Border(
        top: BorderSide(
          color: NeferColors.pharaohGold.withOpacity(0.2),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: BottomNavPatternPainter(
              animation: _shimmerAnimation,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectionIndicator(bool isRTL) {
    return AnimatedBuilder(
      animation: _selectionAnimation,
      builder: (context, child) {
        final itemWidth = MediaQuery.of(context).size.width / widget.items.length;
        final indicatorWidth = itemWidth * 0.6;
        final indicatorLeft = (widget.currentIndex * itemWidth) + 
                            (itemWidth - indicatorWidth) / 2;
        
        return Positioned(
          left: isRTL ? null : indicatorLeft,
          right: isRTL ? indicatorLeft : null,
          top: 4,
          child: Transform.scale(
            scale: _selectionAnimation.value,
            child: Container(
              width: indicatorWidth,
              height: 3,
              decoration: BoxDecoration(
                gradient: NeferColors.pharaohGradient,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: NeferColors.pharaohGold.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationItems(ThemeData theme, bool isRTL) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: widget.items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isSelected = index == widget.currentIndex;
        
        return Expanded(
          child: _buildNavigationItem(
            theme,
            item,
            index,
            isSelected,
            isRTL,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationItem(
    ThemeData theme,
    BottomNavItem item,
    int index,
    bool isSelected,
    bool isRTL,
  ) {
    return AnimatedBuilder(
      animation: _iconAnimations[index],
      builder: (context, child) {
        return GestureDetector(
          onTap: () => widget.onTap(index),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Transform.scale(
                      scale: 1.0 + (0.2 * _iconAnimations[index].value),
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        size: 24,
                        color: isSelected
                            ? NeferColors.pharaohGold
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    
                    // Cart badge
                    if (item.route == '/cart' && widget.cartItemCount > 0)
                      _buildCartBadge(),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: NeferTypography.caption.copyWith(
                    color: isSelected
                        ? NeferColors.pharaohGold
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 10,
                  ),
                  child: Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartBadge() {
    return Positioned(
      right: -6,
      top: -6,
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: NeferColors.error,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: NeferColors.error.withOpacity(0.3 + 0.2 * _shimmerAnimation.value),
                  blurRadius: 3,
                  spreadRadius: 1,
                ),
              ],
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              widget.cartItemCount > 99 ? '99+' : widget.cartItemCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
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

class BottomNavPatternPainter extends CustomPainter {
  final Animation<double> animation;

  BottomNavPatternPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NeferColors.pharaohGold.withOpacity(0.02 + 0.01 * animation.value)
      ..style = PaintingStyle.fill;

    // Draw subtle pharaonic pattern
    final patternHeight = size.height * 0.3;
    final patternY = size.height - patternHeight;
    
    final path = Path();
    
    // Create a subtle wave pattern inspired by Egyptian art
    path.moveTo(0, patternY);
    
    for (double x = 0; x <= size.width; x += 20) {
      final y = patternY + 
                (math.sin((x / size.width) * 2 * math.pi + animation.value * 2 * math.pi) * 2);
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Draw small decorative elements
    _drawDecorativeElements(canvas, size);
  }

  void _drawDecorativeElements(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NeferColors.pharaohGold.withOpacity(0.05 + 0.02 * animation.value)
      ..style = PaintingStyle.fill;

    // Draw small circles as decorative elements
    final spacing = size.width / 10;
    for (int i = 0; i < 10; i++) {
      final x = spacing * i + spacing / 2;
      final y = size.height * 0.2;
      final radius = 1.0 + (0.5 * animation.value);
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
