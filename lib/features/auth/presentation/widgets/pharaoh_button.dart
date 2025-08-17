import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Pharaoh-themed button with golden gradients and Egyptian styling
class PharaohButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const PharaohButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.gradient,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50,
    this.padding,
    this.borderRadius,
    this.boxShadow,
  }) : super(key: key);

  @override
  State<PharaohButton> createState() => _PharaohButtonState();
}

class _PharaohButtonState extends State<PharaohButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: isEnabled ? _handleTapDown : null,
            onTapUp: isEnabled ? _handleTapUp : null,
            onTapCancel: isEnabled ? _handleTapCancel : null,
            onTap: isEnabled ? widget.onPressed : null,
            child: Container(
              width: widget.width,
              height: widget.height,
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                gradient: widget.isOutlined ? null : (widget.gradient ?? _getDefaultGradient()),
                color: widget.isOutlined 
                    ? Colors.transparent 
                    : (widget.backgroundColor ?? (isEnabled ? null : Colors.grey.shade300)),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                border: widget.isOutlined
                    ? Border.all(
                        color: widget.gradient?.colors.first ?? 
                               widget.backgroundColor ?? 
                               NeferColors.pharaohGold,
                        width: 2,
                      )
                    : null,
                boxShadow: widget.isOutlined 
                    ? null 
                    : (widget.boxShadow ?? _getDefaultShadow(isEnabled)),
              ),
              child: Stack(
                children: [
                  // Shimmer effect
                  if (!widget.isOutlined && isEnabled)
                    _buildShimmerEffect(),
                  
                  // Button content
                  Center(
                    child: widget.isLoading
                        ? _buildLoadingIndicator()
                        : _buildButtonContent(),
                  ),
                ],
              ),
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
        return Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
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
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.isOutlined 
              ? (widget.gradient?.colors.first ?? widget.backgroundColor ?? NeferColors.pharaohGold)
              : (widget.textColor ?? Colors.white),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
    final textColor = widget.isOutlined
        ? (widget.gradient?.colors.first ?? widget.backgroundColor ?? NeferColors.pharaohGold)
        : (widget.textColor ?? Colors.white);

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.icon,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: NeferTypography.buttonText.copyWith(
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: NeferTypography.buttonText.copyWith(
        color: textColor,
      ),
    );
  }

  Gradient _getDefaultGradient() {
    return widget.gradient ?? NeferColors.pharaohGradient;
  }

  List<BoxShadow> _getDefaultShadow(bool isEnabled) {
    if (!isEnabled) return [];
    
    return [
      BoxShadow(
        color: NeferColors.goldShadow,
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }
}

/// Small pharaoh button for compact spaces
class PharaohButtonSmall extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;

  const PharaohButtonSmall({
    Key? key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PharaohButton(
      onPressed: onPressed,
      text: text,
      icon: icon,
      isLoading: isLoading,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      borderRadius: BorderRadius.circular(8),
    );
  }
}

/// Outlined pharaoh button
class PharaohButtonOutlined extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final bool isLoading;
  final Color? borderColor;

  const PharaohButtonOutlined({
    Key? key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.isLoading = false,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PharaohButton(
      onPressed: onPressed,
      text: text,
      icon: icon,
      isLoading: isLoading,
      isOutlined: true,
      backgroundColor: borderColor ?? NeferColors.pharaohGold,
    );
  }
}

/// Icon-only pharaoh button
class PharaohIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool hasShadow;

  const PharaohIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.hasShadow = true,
  }) : super(key: key);

  @override
  State<PharaohIconButton> createState() => _PharaohIconButtonState();
}

class _PharaohIconButtonState extends State<PharaohIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            onTap: widget.onPressed,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: NeferColors.pharaohGradient,
                shape: BoxShape.circle,
                boxShadow: widget.hasShadow
                    ? [
                        BoxShadow(
                          color: NeferColors.goldShadow,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                widget.icon,
                color: widget.iconColor ?? Colors.white,
                size: widget.size * 0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}
