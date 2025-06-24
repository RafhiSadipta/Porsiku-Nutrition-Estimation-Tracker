import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:porsiku/constants/constants.dart';

class SectionCard extends StatefulWidget {
  final String? title;
  final Widget contentChild;
  final double titleToContentGap;
  final EdgeInsetsGeometry? margin;
  final bool isLoading;
  final VoidCallback? onTap;
  final bool isExpandable;
  final bool isExpanded;
  final VoidCallback? onExpandToggle;
  final Color? backgroundColor;
  final bool showGradientAccent;
  final IconData? headerIcon;
  final Widget? headerAction;

  const SectionCard({
    super.key,
    this.title,
    required this.contentChild,
    this.titleToContentGap = 12.0,
    this.margin,
    this.isLoading = false,
    this.onTap,
    this.isExpandable = false,
    this.isExpanded = true,
    this.onExpandToggle,
    this.backgroundColor,
    this.showGradientAccent = false,
    this.headerIcon,
    this.headerAction,
  });

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _expandController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    // Hover animation controller
    _hoverController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );

    // Expand animation controller
    _expandController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
      value: widget.isExpanded ? 1.0 : 0.0,
    );

    // Scale animation for hover effect
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );

    // Shadow animation for hover effect
    _shadowAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );

    // Expand animation for collapsible content
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOutCubic,
    );

    // Rotation animation for expand icon
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _expandController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didUpdateWidget(SectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });

    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  void _handleTap() {
    if (widget.isExpandable && widget.onExpandToggle != null) {
      widget.onExpandToggle!();
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_hoverController, _expandController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _handleHover(true),
            onExit: (_) => _handleHover(false),
            child: GestureDetector(
              onTap: _handleTap,
              child: Container(
                width: double.infinity,
                margin:
                    widget.margin ??
                    EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? AppColors.surface,
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  boxShadow: _buildShadow(),
                  border: _buildBorder(),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  child: Stack(
                    children: [
                      // Gradient accent line
                      if (widget.showGradientAccent) _buildGradientAccent(),

                      // Main content
                      Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header section
                            if (widget.title != null &&
                                widget.title!.isNotEmpty)
                              _buildHeader(),

                            // Content section
                            if (widget.isExpandable)
                              SizeTransition(
                                sizeFactor: _expandAnimation,
                                child: _buildContent(),
                              )
                            else
                              _buildContent(),
                          ],
                        ),
                      ),

                      // Loading overlay
                      if (widget.isLoading) _buildLoadingOverlay(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.titleToContentGap),
      child: Row(
        children: [
          // Header icon
          if (widget.headerIcon != null) ...[
            Container(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                  ),
                  child: Icon(
                    widget.headerIcon,
                    size: AppIcons.sm,
                    color: AppColors.primary,
                  ),
                )
                .animate()
                .scale(duration: AppAnimations.medium, curve: Curves.elasticOut)
                .fadeIn(),
            SizedBox(width: AppSpacing.sm),
          ],

          // Title
          Expanded(
            child:
                Text(
                      widget.title!,
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: AppTexts.bold,
                      ),
                    )
                    .animate()
                    .slideX(
                      begin: -0.3,
                      duration: AppAnimations.medium,
                      curve: Curves.easeOutCubic,
                    )
                    .fadeIn(),
          ),

          // Expand button or custom action
          if (widget.isExpandable)
            RotationTransition(
              turns: _rotationAnimation,
              child: IconButton(
                onPressed: widget.onExpandToggle,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                ),
                splashRadius: 20,
              ),
            )
          else if (widget.headerAction != null)
            widget.headerAction!,
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return _buildShimmerContent();
    }

    return widget.contentChild
        .animate()
        .slideY(
          begin: 0.2,
          duration: AppAnimations.slow,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(duration: AppAnimations.slow, curve: Curves.easeOut);
  }

  Widget _buildShimmerContent() {
    return Shimmer.fromColors(
      baseColor: AppAnimationPresets.shimmerBase,
      highlightColor: AppAnimationPresets.shimmerHighlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Container(
            height: 16,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Container(
            height: 16,
            width: MediaQuery.of(context).size.width * 0.5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientAccent() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 4,
        decoration: const BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppBorderRadius.lg),
            topRight: Radius.circular(AppBorderRadius.lg),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      ).animate().fadeIn(duration: AppAnimations.medium),
    );
  }

  List<BoxShadow> _buildShadow() {
    final shadowIntensity = _shadowAnimation.value;

    if (_isHovered) {
      return [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.1 * shadowIntensity),
          blurRadius: 16 * shadowIntensity,
          offset: Offset(0, 8 * shadowIntensity),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.05 * shadowIntensity),
          blurRadius: 8 * shadowIntensity,
          offset: Offset(0, 4 * shadowIntensity),
        ),
      ];
    }

    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.02),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }

  Border? _buildBorder() {
    if (_isHovered) {
      return Border.all(color: AppColors.primary.withOpacity(0.1), width: 1);
    }
    return Border.all(color: AppColors.lightGrey.withOpacity(0.3), width: 0.5);
  }
}
