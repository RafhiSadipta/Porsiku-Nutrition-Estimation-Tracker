import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../constants/constants.dart';
import '../../services/api_service.dart';

class RecipeOpenPage extends StatefulWidget {
  final Map<String, dynamic> recipe;
  const RecipeOpenPage({super.key, required this.recipe});

  @override
  State<RecipeOpenPage> createState() => _RecipeOpenPageState();
}

class _RecipeOpenPageState extends State<RecipeOpenPage>
    with TickerProviderStateMixin {
  Map<String, dynamic>? recipeDetail;
  bool isLoading = true;
  String? errorMessage;
  late ScrollController _scrollController;
  late AnimationController _appBarAnimationController;
  late Animation<double> _appBarOpacity;
  bool _showAppBarTitle = false;

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetail();
    _scrollController = ScrollController();
    _appBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _appBarOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _appBarAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _appBarAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const showAppBarOffset = 120.0;
    if (_scrollController.offset >= showAppBarOffset && !_showAppBarTitle) {
      setState(() => _showAppBarTitle = true);
      _appBarAnimationController.forward();
    } else if (_scrollController.offset < showAppBarOffset &&
        _showAppBarTitle) {
      setState(() => _showAppBarTitle = false);
      _appBarAnimationController.reverse();
    }
  }

  Future<void> _fetchRecipeDetail() async {
    try {
      // Get recipe ID from the basic recipe data
      final recipeId = widget.recipe['id'] as int?;
      if (recipeId != null) {
        final detail = await fetchRecipeDetail(recipeId);
        setState(() {
          recipeDetail = detail;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _buildAnimatedAppBar(),
      body:
          isLoading
              ? _buildLoadingState()
              : errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  PreferredSizeWidget _buildAnimatedAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: AnimatedBuilder(
        animation: _appBarOpacity,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(_appBarOpacity.value * 0.95),
              boxShadow:
                  _appBarOpacity.value > 0
                      ? [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                      : [],
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leadingWidth: 72, // Accommodate padding
              titleSpacing: 0, // Remove default title spacing
              leading: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: _EnhancedCircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).pop(),
                    backgroundColor:
                        _showAppBarTitle
                            ? AppColors.white
                            : AppColors.white.withOpacity(0.9),
                  ),
                ),
              ),
              title: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: AnimatedOpacity(
                  opacity: _appBarOpacity.value,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    recipeDetail?['title'] ??
                        widget.recipe['title'] ??
                        'Recipe',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        // Hero image skeleton
        Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withOpacity(0.3),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(AppBorderRadius.xl),
                ),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(
              duration: const Duration(seconds: 2),
              color: AppColors.white.withOpacity(0.8),
            ),

        Expanded(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Title skeleton
                Container(
                      height: 28,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                      duration: const Duration(seconds: 2),
                      color: AppColors.white.withOpacity(0.8),
                    ),

                SizedBox(height: AppSpacing.lg),

                // Content skeletons
                ...List.generate(
                  3,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.md),
                    child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.lg,
                            ),
                          ),
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(
                          duration: const Duration(seconds: 2),
                          color: AppColors.white.withOpacity(0.8),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: AppColors.error,
                  ),
                )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(),

            SizedBox(height: AppSpacing.lg),

            Text(
                  'Failed to load recipe',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                )
                .animate()
                .fadeIn(delay: 200.ms)
                .slideY(begin: 0.3, duration: 600.ms),

            SizedBox(height: AppSpacing.sm),

            Text(
                  errorMessage ?? 'Something went wrong',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                )
                .animate()
                .fadeIn(delay: 400.ms)
                .slideY(begin: 0.3, duration: 600.ms),

            SizedBox(height: AppSpacing.xl),

            Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_back_rounded, size: 18),
                      label: Text('Go Back'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightGrey,
                        foregroundColor: AppColors.textPrimary,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.md,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                          errorMessage = null;
                        });
                        _fetchRecipeDetail();
                      },
                      icon: Icon(Icons.refresh_rounded, size: 18),
                      label: Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.md,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                .animate()
                .fadeIn(delay: 600.ms)
                .scaleXY(
                  begin: 0.8,
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          // Hero Image Section
          _buildHeroSection(),

          // Content Section
          Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Action Buttons
                _buildTitleSection()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(
                      begin: 0.3,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                    ),

                SizedBox(height: AppSpacing.lg),

                // Meta Information
                _buildMetaSection()
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .slideY(
                      begin: 0.3,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                    ),

                SizedBox(height: AppSpacing.lg),

                // Description
                if (recipeDetail?['summary'] != null ||
                    _dummyDescription.isNotEmpty)
                  _buildDescriptionSection()
                      .animate()
                      .fadeIn(duration: 600.ms, delay: 400.ms)
                      .slideY(
                        begin: 0.3,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      ),

                SizedBox(height: AppSpacing.lg),

                // Nutrition Information
                _buildNutritionSection()
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms)
                    .slideY(
                      begin: 0.3,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                    ),

                SizedBox(height: AppSpacing.xl),

                // Ingredients Section
                _buildIngredientsSection()
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 800.ms)
                    .slideY(
                      begin: 0.3,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                    ),

                SizedBox(height: AppSpacing.lg),

                // Instructions Section
                _buildInstructionsSection()
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 1000.ms)
                    .slideY(
                      begin: 0.3,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                    ),

                SizedBox(height: AppSpacing.xl * 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 280,
      width: double.infinity,
      child: Stack(
        children: [
          // Hero Image
          Hero(
            tag: 'recipe_image_${widget.recipe['id'] ?? 'default'}',
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(AppBorderRadius.xl),
                ),
                image: DecorationImage(
                  image: NetworkImage(
                    recipeDetail?['image'] ??
                        widget.recipe['image'] ??
                        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&h=280&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(AppBorderRadius.xl),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.black.withOpacity(0.3)],
              ),
            ),
          ),

          // Floating Action Buttons
          Positioned(
                bottom: AppSpacing.lg,
                right: AppSpacing.lg,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FloatingActionChip(
                      icon: Icons.bookmark_outline_rounded,
                      label: 'Favorite',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Implement save functionality
                      },
                    ),
                    SizedBox(width: AppSpacing.sm),
                    _FloatingActionChip(
                      icon: Icons.add_rounded,
                      label: 'Add to Meal',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // TODO: Implement add to meal functionality
                      },
                      isPrimary: true,
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: 800.ms, duration: 600.ms)
              .slideY(begin: 0.3, duration: 800.ms, curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipeDetail?['title'] ??
              widget.recipe['title'] ??
              'Delicious Recipe',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildMetaSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MetaInfoCard(
            icon: Icons.access_time_rounded,
            value:
                '${recipeDetail?['readyInMinutes'] ?? widget.recipe['readyInMinutes'] ?? 45}',
            unit: 'min',
            label: 'Cook time',
            color: AppColors.secondary,
          ),
          _MetaInfoCard(
            icon: Icons.restaurant_rounded,
            value:
                '${recipeDetail?['servings'] ?? widget.recipe['servings'] ?? 4}',
            unit: '',
            label: 'Servings',
            color: AppColors.secondary,
          ),
          _MetaInfoCard(
            icon: Icons.shopping_cart_rounded,
            value:
                '${(recipeDetail?['ingredients'] as List<dynamic>?)?.length ?? (widget.recipe['ingredients'] as List<dynamic>?)?.length ?? 0}',
            unit: '',
            label: 'Ingredients',
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'About this recipe',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.md),

          _EnhancedDescriptionText(
            recipeDetail?['summary'] ?? _dummyDescription,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSection() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Nutrition per serving',
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.2,
            children: [
              _NutritionCard(
                icon: Icons.local_fire_department_rounded,
                label: 'Calories',
                value:
                    '${recipeDetail?['nutrition']?['calories']?.toInt() ?? (widget.recipe['calories'] as num?)?.toInt() ?? 120}',
                unit: 'kcal',
                color: AppColors.blue,
              ),
              _NutritionCard(
                icon: Icons.fitness_center_rounded,
                label: 'Protein',
                value:
                    '${recipeDetail?['nutrition']?['protein']?.toInt() ?? (widget.recipe['protein'] as num?)?.toInt() ?? 21}',
                unit: 'g',
                color: const Color(0xFFE7000B),
              ),
              _NutritionCard(
                icon: Icons.bakery_dining_rounded,
                label: 'Carbs',
                value:
                    '${recipeDetail?['nutrition']?['carbohydrates']?.toInt() ?? (widget.recipe['carbs'] as num?)?.toInt() ?? 50}',
                unit: 'g',
                color: AppColors.warning,
              ),
              _NutritionCard(
                icon: Icons.eco_rounded,
                label: 'Fats',
                value:
                    '${recipeDetail?['nutrition']?['fat']?.toInt() ?? (widget.recipe['fat'] as num?)?.toInt() ?? 8}',
                unit: 'g',
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return _EnhancedSectionCard(
      title: 'Ingredients',
      icon: Icons.shopping_cart_rounded,
      children: _buildIngredientsList(),
    );
  }

  Widget _buildInstructionsSection() {
    return _EnhancedSectionCard(
      title: 'Instructions',
      icon: Icons.list_alt_rounded,
      children: _buildInstructionsList(),
    );
  }

  List<Widget> _buildIngredientsList() {
    final ingredients = recipeDetail?['ingredients'] as List<dynamic>?;
    if (ingredients != null && ingredients.isNotEmpty) {
      return ingredients.asMap().entries.map((entry) {
        return _EnhancedIngredientRow(
          text: entry.value.toString(),
          index: entry.key,
        );
      }).toList();
    } else {
      return List.generate(
        _dummyIngredients.length,
        (i) => _EnhancedIngredientRow(text: _dummyIngredients[i], index: i),
      );
    }
  }

  List<Widget> _buildInstructionsList() {
    final instructions = recipeDetail?['instructions'] as List<dynamic>?;
    if (instructions != null && instructions.isNotEmpty) {
      return instructions.asMap().entries.map((entry) {
        return _EnhancedInstructionRow(
          number: entry.key + 1,
          text: entry.value.toString(),
          index: entry.key,
        );
      }).toList();
    } else {
      return List.generate(
        _dummyInstructions.length,
        (i) => _EnhancedInstructionRow(
          number: i + 1,
          text: _dummyInstructions[i],
          index: i,
        ),
      );
    }
  }
}

// Enhanced Components
class _EnhancedCircleButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? backgroundColor;

  const _EnhancedCircleButton({
    required this.icon,
    required this.onTap,
    this.backgroundColor,
  });

  @override
  State<_EnhancedCircleButton> createState() => _EnhancedCircleButtonState();
}

class _EnhancedCircleButtonState extends State<_EnhancedCircleButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? AppColors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  HapticFeedback.lightImpact();
                  widget.onTap();
                },
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                child: Icon(
                  widget.icon,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FloatingActionChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _FloatingActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  State<_FloatingActionChip> createState() => _FloatingActionChipState();
}

class _FloatingActionChipState extends State<_FloatingActionChip>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
              gradient: widget.isPrimary ? AppGradients.primary : null,
              color:
                  widget.isPrimary ? null : AppColors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(AppBorderRadius.xl),
              boxShadow: [
                BoxShadow(
                  color:
                      widget.isPrimary
                          ? AppColors.primary.withOpacity(0.3)
                          : AppColors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                onTap: () {
                  widget.onTap();
                },
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.icon,
                        color:
                            widget.isPrimary
                                ? AppColors.white
                                : AppColors.textPrimary,
                        size: 18,
                      ),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        widget.label,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color:
                              widget.isPrimary
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
}

class _MetaInfoCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final String label;
  final Color color;

  const _MetaInfoCard({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
          ),
          child: Icon(icon, color: color, size: 24),
        ),

        SizedBox(height: AppSpacing.sm),

        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (unit.isNotEmpty)
                TextSpan(
                  text: unit,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),

        SizedBox(height: 2),

        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _NutritionCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(
            '$value$unit',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnhancedSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _EnhancedSectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.lg),

          ...children,
        ],
      ),
    );
  }
}

class _EnhancedDescriptionText extends StatelessWidget {
  final String text;

  const _EnhancedDescriptionText(this.text);

  List<TextSpan> _parseHtmlToTextSpans(String htmlString) {
    List<TextSpan> spans = [];

    // Split by bold tags and process each part
    List<String> parts = htmlString.split(RegExp(r'</?b>'));
    bool isBold = false;

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isEmpty) {
        isBold = !isBold;
        continue;
      }

      String cleanText = parts[i]
          .replaceAll(
            RegExp(r'<a [^>]*>(.*?)</a>'),
            r'$1',
          ) // Remove link tags but keep content
          .replaceAll(RegExp(r'<[^>]*>'), '') // Remove any other HTML tags
          .replaceAll('&nbsp;', ' ') // Replace HTML entities
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"')
          .replaceAll('&#39;', "'");

      if (cleanText.isNotEmpty) {
        spans.add(
          TextSpan(
            text: cleanText,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.6,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        );
      }

      isBold = !isBold;
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: _parseHtmlToTextSpans(text)),
      textAlign: TextAlign.justify,
    );
  }
}

class _EnhancedIngredientRow extends StatelessWidget {
  final String text;
  final int index;

  const _EnhancedIngredientRow({required this.text, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: EdgeInsets.only(bottom: AppSpacing.sm),
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            border: Border.all(
              color: AppColors.lightGrey.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: AppColors.white,
                  size: 16,
                ),
              ),

              SizedBox(width: AppSpacing.md),

              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          duration: Duration(milliseconds: 400),
          delay: Duration(milliseconds: index * 100),
        )
        .slideX(
          begin: 0.3,
          duration: Duration(milliseconds: 600),
          delay: Duration(milliseconds: index * 100),
          curve: Curves.easeOutCubic,
        );
  }
}

class _EnhancedInstructionRow extends StatelessWidget {
  final int number;
  final String text;
  final int index;

  const _EnhancedInstructionRow({
    required this.number,
    required this.text,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  number.toString(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(width: AppSpacing.md),

              Expanded(
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(
                      color: AppColors.lightGrey.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          duration: Duration(milliseconds: 400),
          delay: Duration(milliseconds: index * 150),
        )
        .slideX(
          begin: 0.3,
          duration: Duration(milliseconds: 600),
          delay: Duration(milliseconds: index * 150),
          curve: Curves.easeOutCubic,
        );
  }
}

// Dummy data for preview
const _dummyDescription =
    'This delicious and nutritious recipe combines fresh ingredients with bold flavors to create a meal that\'s both satisfying and healthy. Perfect for busy weeknights or special occasions, this dish brings together the best of traditional cooking with modern nutritional awareness. Each serving provides a balanced mix of proteins, carbohydrates, and essential vitamins to fuel your day.';

const List<String> _dummyIngredients = [
  '2 cups of fresh vegetables (mixed)',
  '1 pound of lean protein (chicken, fish, or tofu)',
  '2 tablespoons of olive oil',
  '1 onion, finely chopped',
  '3 cloves of garlic, minced',
  '1 cup of whole grain rice or quinoa',
  'Salt and pepper to taste',
  'Fresh herbs for garnish',
];

const List<String> _dummyInstructions = [
  'Prepare all ingredients by washing, chopping, and measuring them according to the recipe requirements.',
  'Heat olive oil in a large pan over medium-high heat. Add onions and cook until translucent, about 3-4 minutes.',
  'Add garlic and cook for another minute until fragrant. Be careful not to burn the garlic.',
  'Add your protein choice to the pan and cook until browned on all sides and cooked through.',
  'Add vegetables to the pan and stir-fry for 5-7 minutes until they are tender-crisp.',
  'Season with salt, pepper, and any additional spices. Stir everything together.',
  'Serve hot over cooked rice or quinoa, garnished with fresh herbs.',
  'Enjoy your delicious and nutritious meal!',
];
