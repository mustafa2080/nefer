import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Pharaoh-themed text field with golden accents and Egyptian styling
class PharaohTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;

  const PharaohTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.enabled = true,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.onSubmitted,
  }) : super(key: key);

  @override
  State<PharaohTextField> createState() => _PharaohTextFieldState();
}

class _PharaohTextFieldState extends State<PharaohTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  late Animation<Color?> _borderColorAnimation;
  late Animation<Color?> _labelColorAnimation;
  
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _focusAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _borderColorAnimation = ColorTween(
      begin: NeferColors.hieroglyphGray.withOpacity(0.3),
      end: NeferColors.pharaohGold,
    ).animate(_focusAnimation);

    _labelColorAnimation = ColorTween(
      begin: NeferColors.hieroglyphGray.withOpacity(0.7),
      end: NeferColors.pharaohGold,
    ).animate(_focusAnimation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange(bool hasFocus) {
    setState(() {
      _isFocused = hasFocus;
    });

    if (hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _validateField(String? value) {
    if (widget.validator != null) {
      final error = widget.validator!(value);
      setState(() {
        _hasError = error != null;
        _errorText = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            if (widget.labelText != null) ...[
              Text(
                widget.labelText!,
                style: NeferTypography.bodyMedium.copyWith(
                  color: _hasError 
                      ? NeferColors.error 
                      : _labelColorAnimation.value,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            // Text field container
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (_isFocused)
                    BoxShadow(
                      color: NeferColors.pharaohGold.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                readOnly: widget.readOnly,
                enabled: widget.enabled,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                inputFormatters: widget.inputFormatters,
                textCapitalization: widget.textCapitalization,
                textInputAction: widget.textInputAction,
                style: NeferTypography.bodyMedium.copyWith(
                  color: NeferColors.hieroglyphGray,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: NeferTypography.bodyMedium.copyWith(
                    color: NeferColors.hieroglyphGray.withOpacity(0.5),
                  ),
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                          widget.prefixIcon,
                          color: _hasError 
                              ? NeferColors.error 
                              : _isFocused 
                                  ? NeferColors.pharaohGold 
                                  : NeferColors.hieroglyphGray.withOpacity(0.7),
                        )
                      : null,
                  suffixIcon: widget.suffixIcon,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: NeferColors.hieroglyphGray.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _hasError 
                          ? NeferColors.error 
                          : NeferColors.hieroglyphGray.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _hasError 
                          ? NeferColors.error 
                          : _borderColorAnimation.value!,
                      width: 2.0,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: NeferColors.error,
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: NeferColors.error,
                      width: 2.0,
                    ),
                  ),
                  errorStyle: const TextStyle(height: 0),
                ),
                onTap: widget.onTap,
                onChanged: (value) {
                  widget.onChanged?.call(value);
                  _validateField(value);
                },
                onFieldSubmitted: widget.onSubmitted,
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
                validator: (value) {
                  _validateField(value);
                  return _hasError ? '' : null; // Return empty string to show error styling
                },
              ),
            ),
            
            // Error message
            if (_hasError && _errorText != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: NeferColors.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _errorText!,
                      style: NeferTypography.bodySmall.copyWith(
                        color: NeferColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Pharaoh-themed search field with special styling
class PharaohSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;
  final bool showFilter;
  final VoidCallback? onFilterTap;

  const PharaohSearchField({
    Key? key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.showFilter = false,
    this.onFilterTap,
  }) : super(key: key);

  @override
  State<PharaohSearchField> createState() => _PharaohSearchFieldState();
}

class _PharaohSearchFieldState extends State<PharaohSearchField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = widget.controller?.text.isNotEmpty ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: NeferColors.lightShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        style: NeferTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search products...',
          hintStyle: NeferTypography.bodyMedium.copyWith(
            color: NeferColors.hieroglyphGray.withOpacity(0.5),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: NeferColors.pharaohGold,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_hasText)
                IconButton(
                  onPressed: () {
                    widget.controller?.clear();
                    widget.onClear?.call();
                  },
                  icon: const Icon(
                    Icons.clear,
                    color: NeferColors.hieroglyphGray,
                  ),
                ),
              if (widget.showFilter)
                IconButton(
                  onPressed: widget.onFilterTap,
                  icon: const Icon(
                    Icons.tune,
                    color: NeferColors.pharaohGold,
                  ),
                ),
            ],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
}
