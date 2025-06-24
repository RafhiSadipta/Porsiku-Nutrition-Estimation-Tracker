import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:porsiku/constants/constants.dart';

class Option extends StatefulWidget {
  final IconData? icon;
  final String label;
  final String? description;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leadingWidget;
  final Color? iconColor;

  const Option({
    super.key,
    this.icon,
    required this.label,
    this.description,
    required this.selected,
    required this.onTap,
    this.leadingWidget,
    this.iconColor,
  }) : assert(
         icon != null || leadingWidget != null || description != null,
         'Either icon, leadingWidget or description must be provided if label is the only other required field for visual output',
       );

  @override
  State<Option> createState() => _OptionState();
}

class _OptionState extends State<Option> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap();
            },
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color:
                    widget.selected
                        ? AppColors.primary.withOpacity(0.05)
                        : AppColors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                border: Border.all(
                  color:
                      widget.selected
                          ? AppColors.primary
                          : AppColors.lightGrey.withOpacity(0.5),
                  width: widget.selected ? 1 : 1,
                ),
                boxShadow:
                    widget.selected
                        ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                        : [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.03),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
              ),
              child: Row(
                children: [
                  if (widget.leadingWidget != null)
                    widget.leadingWidget!
                  else if (widget.icon != null)
                    Container(
                      padding: EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color:
                            widget.selected
                                ? AppColors.primary.withOpacity(0.2)
                                : AppColors.lightGrey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      ),
                      child: Icon(
                        widget.icon!,
                        color:
                            widget.iconColor ??
                            (widget.selected
                                ? AppColors.primary
                                : AppColors.textSecondary),
                        size: 18,
                      ),
                    ),
                  if (widget.leadingWidget != null || widget.icon != null)
                    SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.label,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color:
                                widget.selected
                                    ? AppColors.textPrimary
                                    : AppColors.textPrimary,
                            fontWeight:
                                widget.selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                          ),
                        ),
                        if (widget.description != null &&
                            widget.description!.isNotEmpty) ...[
                          SizedBox(height: AppSpacing.xs / 2),
                          Text(
                            widget.description!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color:
                                  widget.selected
                                      ? AppColors.primary.withOpacity(0.8)
                                      : AppColors.grey,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.selected)
                    Container(
                      padding: EdgeInsets.all(AppSpacing.xs / 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: AppColors.white,
                        size: 14,
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
}
