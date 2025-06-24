import 'package:flutter/material.dart';
import 'package:porsiku/constants/constants.dart';

class InputField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final String? errorText;
  final bool enabled;

  const InputField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.prefixIcon,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.enabled = true,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> with TickerProviderStateMixin {
  bool _obscureText = true;
  bool _isFocused = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
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
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              boxShadow: _isFocused ? AppShadows.card : [],
            ),
            child: TextField(
              controller: widget.controller,
              obscureText: _obscureText,
              keyboardType: widget.keyboardType ?? TextInputType.text,
              textInputAction: widget.textInputAction,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              enabled: widget.enabled,
              style: AppTextStyles.bodyLarge.copyWith(
                color: widget.enabled ? AppColors.textPrimary : AppColors.grey,
              ),
              onTap: () {
                setState(() {
                  _isFocused = true;
                });
                _animationController.forward();
              },
              onEditingComplete: () {
                setState(() {
                  _isFocused = false;
                });
                _animationController.reverse();
              },
              onTapOutside: (event) {
                setState(() {
                  _isFocused = false;
                });
                _animationController.reverse();
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                labelText: widget.labelText,
                hintText: widget.hintText,
                errorText: widget.errorText,
                filled: true,
                fillColor:
                    widget.enabled ? AppColors.white : AppColors.lightGrey,
                contentPadding: EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                  horizontal: AppSpacing.lg,
                ),
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.grey,
                ),
                labelStyle: AppTextStyles.bodyMedium.copyWith(
                  color: _isFocused ? AppColors.primary : AppColors.grey,
                ),
                errorStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  borderSide: BorderSide(
                    color: AppColors.lightGrey,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  borderSide: BorderSide(
                    color: AppColors.lightGrey,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  borderSide: BorderSide(color: AppColors.error, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  borderSide: BorderSide(color: AppColors.error, width: 2),
                ),
                prefixIcon:
                    widget.prefixIcon != null
                        ? Padding(
                          padding: EdgeInsets.only(left: AppSpacing.sm),
                          child: widget.prefixIcon,
                        )
                        : null,
                suffixIcon:
                    widget.isPassword
                        ? IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color:
                                _isFocused ? AppColors.primary : AppColors.grey,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        )
                        : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
