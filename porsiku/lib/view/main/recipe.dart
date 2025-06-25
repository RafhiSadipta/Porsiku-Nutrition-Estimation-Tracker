import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../constants/constants.dart';
import 'recipe_open.dart';
import '../../components/filter_recipe_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key});

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  List<Map<String, dynamic>> recipes = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  String? errorMsg;
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? currentFilters;
  Timer? _debounceTimer;
  final ScrollController _scrollController = ScrollController();
  int currentOffset = 0;
  static const int pageSize = 20;
  @override
  void initState() {
    super.initState();
    fetchRecipes();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchRecipes({
    Map<String, dynamic>? filterData,
    bool isLoadMore = false,
  }) async {
    if (isLoadMore) {
      if (isLoadingMore || !hasMoreData) return;
      setState(() {
        isLoadingMore = true;
      });
    } else {
      setState(() {
        isLoading = true;
        errorMsg = null;
        currentOffset = 0;
        hasMoreData = true;
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // Prepare the request payload
      Map<String, dynamic> payload = {};

      // Add pagination parameters
      payload['number'] = pageSize;
      payload['offset'] = isLoadMore ? currentOffset : 0;

      // Add search query if exists
      if (_searchController.text.isNotEmpty) {
        payload['query'] = _searchController.text;
      }

      // Add filters if exists
      if (filterData != null) {
        payload.addAll(filterData);
        if (!isLoadMore) {
          currentFilters =
              filterData; // Store current filters only on new search
        }
      } else if (currentFilters != null) {
        payload.addAll(currentFilters!); // Use stored filters for load more
      }

      final response = await http.post(
        Uri.parse(
          'https://porsiku-nutrition-estimation-tracker-production.up.railway.app/api/resep',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (data['data'] != null &&
              data['data']['results'] != null &&
              data['data']['results'] is List) {
            final newRecipes = List<Map<String, dynamic>>.from(
              data['data']['results'],
            );

            if (isLoadMore) {
              recipes.addAll(newRecipes);
              currentOffset += pageSize;
            } else {
              recipes = newRecipes;
              currentOffset = pageSize;
            }

            // Check if we have more data
            hasMoreData = newRecipes.length == pageSize;
          } else {
            if (!isLoadMore) {
              recipes = [];
              errorMsg = 'Format data resep tidak dikenali.';
            }
          }
          isLoading = false;
          isLoadingMore = false;
        });
      } else {
        setState(() {
          if (!isLoadMore) {
            errorMsg =
                'Gagal fetch resep: ${response.statusCode}\n${response.body}';
          }
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        if (!isLoadMore) {
          errorMsg = 'Error: $e';
        }
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  // Pull to refresh - clears all filters and search
  Future<void> _onRefresh() async {
    setState(() {
      _searchController.clear();
      currentFilters = null;
    });
    await fetchRecipes();
  }

  // Scroll listener for infinite scroll
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when user is 200 pixels away from the bottom
      fetchRecipes(isLoadMore: true);
    }
  }

  // Search functionality with debounce
  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) {
        fetchRecipes(filterData: currentFilters);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  search and filter row
              Row(
                children: [
                  //  filter button
                  Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppGradients.primary,
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.md,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              AppBorderRadius.md,
                            ),
                            onTap: () async {
                              HapticFeedback.lightImpact();
                              final result = await FilterRecipeBottomSheet.show(
                                context,
                              );
                              if (result != null) {
                                setState(() {
                                  isLoading = true;
                                });
                                await fetchRecipes(filterData: result);
                              }
                            },
                            child: Icon(
                              Icons.tune_rounded,
                              color: AppColors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .scale(duration: 400.ms, curve: Curves.elasticOut)
                      .fadeIn(duration: 300.ms),

                  SizedBox(width: AppSpacing.sm),

                  //  search bar
                  Expanded(
                    child: _SearchBar(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.lg),

              //  content area
              if (isLoading)
                Expanded(child: _buildLoadingState())
              else if (errorMsg != null)
                Expanded(child: _buildErrorState())
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: AppColors.primary,
                    backgroundColor: AppColors.white,
                    child: Column(
                      children: [
                        // Results summary
                        if (recipes.isNotEmpty) ...[
                          Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${recipes.length} recipes found',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (currentFilters != null ||
                                      _searchController.text.isNotEmpty)
                                    TextButton.icon(
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          currentFilters = null;
                                        });
                                        fetchRecipes();
                                      },
                                      icon: Icon(
                                        Icons.clear_rounded,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      label: Text(
                                        'Clear',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: 0.3, duration: 400.ms),

                          SizedBox(height: AppSpacing.sm),
                        ], //  grid
                        Expanded(
                          child:
                              recipes.isEmpty
                                  ? _buildEmptyState()
                                  : SingleChildScrollView(
                                    controller: _scrollController,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        // Calculate how many columns can fit
                                        const double cardMinWidth = 160;
                                        const double spacing = 12;
                                        final int crossAxisCount =
                                            ((constraints.maxWidth + spacing) /
                                                    (cardMinWidth + spacing))
                                                .floor()
                                                .clamp(2, 4);
                                        final double cardWidth =
                                            (constraints.maxWidth -
                                                (spacing *
                                                    (crossAxisCount - 1))) /
                                            crossAxisCount;

                                        return Wrap(
                                          spacing: spacing,
                                          runSpacing: spacing,
                                          children:
                                              recipes.asMap().entries.map((
                                                entry,
                                              ) {
                                                final int index = entry.key;
                                                final Map<String, dynamic>
                                                recipe = entry.value;
                                                return SizedBox(
                                                  width: cardWidth,
                                                  child: RecipeCard(
                                                    recipe: recipe,
                                                    index: index,
                                                  ),
                                                );
                                              }).toList(),
                                        );
                                      },
                                    ),
                                  ),
                        ),

                        // Loading more indicator
                        if (isLoadingMore)
                          Container(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary,
                                    ),
                                  ),
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Loading more recipes...',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (!hasMoreData && recipes.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 16,
                                  color: AppColors.success,
                                ),
                                SizedBox(width: AppSpacing.xs),
                                Text(
                                  'All recipes loaded',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double cardMinWidth = 160;
          const double spacing = 12;
          final int crossAxisCount = ((constraints.maxWidth + spacing) /
                  (cardMinWidth + spacing))
              .floor()
              .clamp(2, 4);
          final double cardWidth =
              (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
              crossAxisCount;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: List.generate(6, (index) {
              return SizedBox(
                width: cardWidth,
                height: 240, // Fixed height for loading placeholders
                child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                      duration: const Duration(seconds: 2),
                      color: AppColors.white.withOpacity(0.8),
                    ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
              )
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(),

          SizedBox(height: AppSpacing.md),

          Text(
                'Oops! Something went wrong',
                style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
              )
              .animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.3, duration: 600.ms),

          SizedBox(height: AppSpacing.sm),

          Text(
                errorMsg ?? 'Failed to load recipes',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.3, duration: 600.ms),

          SizedBox(height: AppSpacing.lg),

          ElevatedButton.icon(
                onPressed: () => fetchRecipes(),
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
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: 600.ms)
              .scaleXY(begin: 0.8, duration: 600.ms, curve: Curves.elasticOut),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                padding: EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  gradient: AppGradients.subtle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu_outlined,
                  size: 64,
                  color: AppColors.primary,
                ),
              )
              .animate()
              .scale(duration: 800.ms, curve: Curves.elasticOut)
              .fadeIn(),

          SizedBox(height: AppSpacing.lg),

          Text(
                'No recipes found',
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              )
              .animate()
              .fadeIn(delay: 300.ms)
              .slideY(begin: 0.3, duration: 600.ms),

          SizedBox(height: AppSpacing.sm),

          Text(
                'Try adjusting your search or filters',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
              .animate()
              .fadeIn(delay: 500.ms)
              .slideY(begin: 0.3, duration: 600.ms),
        ],
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _borderAnimation = Tween<double>(begin: 1.0, end: 2.0).animate(
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
      animation: _borderAnimation,
      builder: (context, child) {
        return Container(
          height: AppSpacing.xxl,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            border: Border.all(
              color:
                  _isFocused
                      ? AppColors.primary
                      : AppColors.darkGrey.withOpacity(0.3),
              width: _borderAnimation.value,
            ),
          ),
          child: Row(
            children: [
              // Leading icon
              Padding(
                padding: EdgeInsets.only(left: AppSpacing.md),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.search_rounded,
                    color:
                        _isFocused
                            ? AppColors.primary
                            : AppColors.textSecondary,
                    size: AppTexts.lg,
                  ),
                ),
              ),

              SizedBox(width: AppSpacing.sm),

              // Text field
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  onChanged: (_) => widget.onChanged(),
                  textAlignVertical: TextAlignVertical.center,
                  onTap: () {
                    setState(() => _isFocused = true);
                    _animationController.forward();
                    HapticFeedback.selectionClick();
                  },
                  onTapOutside: (_) {
                    setState(() => _isFocused = false);
                    _animationController.reverse();
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari resep favorit...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  cursorColor: AppColors.primary,
                  cursorWidth: 2,
                ),
              ),

              // Clear button
              if (widget.controller.text.isNotEmpty)
                Padding(
                      padding: EdgeInsets.only(right: AppSpacing.xs),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            widget.controller.clear();
                            widget.onChanged();
                            HapticFeedback.lightImpact();
                          },
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.sm,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(AppSpacing.xs),
                            child: Icon(
                              Icons.close_rounded,
                              color: AppColors.textSecondary,
                              size: AppTexts.ml,
                            ),
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .scale(duration: 200.ms, curve: Curves.elasticOut)
                    .fadeIn(duration: 150.ms),

              SizedBox(width: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }
}

class RecipeCard extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final int index;

  const RecipeCard({super.key, required this.recipe, required this.index});

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 2, end: 8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: GestureDetector(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              RecipeOpenPage(recipe: widget.recipe),
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOutCubic,
                            ),
                          ),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                },
                child: IntrinsicHeight(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.05),
                          blurRadius: _elevationAnimation.value,
                          offset: Offset(0, _elevationAnimation.value / 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //  image with hero animation
                        AspectRatio(
                          aspectRatio: 1.2, // Fixed aspect ratio for image only
                          child: Hero(
                            tag:
                                'recipe_image_${widget.recipe['id'] ?? widget.index}',
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(AppBorderRadius.lg),
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    widget.recipe['image'] ?? defaultImage(),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Gradient overlay
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(
                                          AppBorderRadius.lg,
                                        ),
                                      ),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          AppColors.black.withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Time badge
                                  Positioned(
                                        top: AppSpacing.sm,
                                        left: AppSpacing.sm,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: AppSpacing.sm,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.black.withOpacity(
                                              0.7,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              AppBorderRadius.xl,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.access_time_rounded,
                                                color: AppColors.white,
                                                size: 14,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                widget.recipe['readyInMinutes'] !=
                                                        null
                                                    ? '${widget.recipe['readyInMinutes']}m'
                                                    : '-',
                                                style: AppTextStyles.caption
                                                    .copyWith(
                                                      color: AppColors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(
                                        delay: Duration(
                                          milliseconds: widget.index * 100,
                                        ),
                                      )
                                      .scaleXY(
                                        begin: 0.8,
                                        duration: 400.ms,
                                        curve: Curves.elasticOut,
                                      ),

                                  // Bookmark button
                                  Positioned(
                                        top: AppSpacing.sm,
                                        right: AppSpacing.sm,
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: AppColors.white.withOpacity(
                                              0.9,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              AppBorderRadius.sm,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppBorderRadius.sm,
                                                  ),
                                              onTap: () {
                                                HapticFeedback.lightImpact();
                                                // TODO: Implement bookmark functionality
                                              },
                                              child: Icon(
                                                (widget.recipe['isBookmarked'] ==
                                                        true)
                                                    ? Icons.bookmark_rounded
                                                    : Icons
                                                        .bookmark_border_rounded,
                                                color: AppColors.primary,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(
                                        delay: Duration(
                                          milliseconds:
                                              widget.index * 100 + 200,
                                        ),
                                      )
                                      .scaleXY(
                                        begin: 0.8,
                                        duration: 400.ms,
                                        curve: Curves.elasticOut,
                                      ),
                                ],
                              ),
                            ),
                          ),
                        ), // Content section
                        Padding(
                          padding: EdgeInsets.all(AppSpacing.sm),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title section - natural height
                              Text(
                                widget.recipe['title'] ?? 'Untitled Recipe',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  height: 1.2,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              SizedBox(height: AppSpacing.sm),

                              // Nutrition pills
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  _NutriPill(
                                    icon: Icons.local_fire_department_rounded,
                                    color: AppColors.blue,
                                    label:
                                        '${(widget.recipe['calories'] as num?)?.toInt() ?? 0}cal',
                                  ),
                                  _NutriPill(
                                    icon: Icons.fitness_center_rounded,
                                    color: AppColors.red,
                                    label:
                                        '${(widget.recipe['protein'] as num?)?.toInt() ?? 0}g',
                                  ),
                                  _NutriPill(
                                    icon: Icons.bakery_dining_rounded,
                                    color: AppColors.warning,
                                    label:
                                        '${(widget.recipe['carbs'] as num?)?.toInt() ?? 0}g',
                                  ),
                                  _NutriPill(
                                    icon: Icons.eco_rounded,
                                    color: AppColors.success,
                                    label:
                                        '${(widget.recipe['fat'] as num?)?.toInt() ?? 0}g',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        )
        .animate()
        .fadeIn(
          duration: Duration(milliseconds: 400),
          delay: Duration(milliseconds: widget.index * 100),
        )
        .slideY(
          begin: 0.3,
          duration: Duration(milliseconds: 600),
          delay: Duration(milliseconds: widget.index * 100),
          curve: Curves.easeOutCubic,
        );
  }
}

class _NutriPill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _NutriPill({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// Dummy data untuk preview UI
defaultImage() =>
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&h=180&q=80';
// Make _dummyRecipes public for dashboard import
List<Map<String, dynamic>> dummyRecipes = [
  {
    'image': defaultImage(),
    'duration': '4min',
    'title': 'Oatmeal Medan Besi',
    'isBookmarked': false,
    'calories': '120',
    'protein': '21',
    'weight': '500',
    'fiber': '8',
  },
  {
    'image': defaultImage(),
    'duration': '4min',
    'title': 'Opor Ayam Wenak',
    'isBookmarked': true,
    'calories': '120',
    'protein': '21',
    'weight': '500',
    'fiber': '8',
  },
  {
    'image': defaultImage(),
    'duration': '4min',
    'title': 'Telur Dadar Elite',
    'isBookmarked': false,
    'calories': '120',
    'protein': '21',
    'weight': '500',
    'fiber': '8',
  },
  {
    'image': defaultImage(),
    'duration': '4min',
    'title': 'Prak Prak Ketoprak',
    'isBookmarked': false,
    'calories': '120',
    'protein': '21',
    'weight': '500',
    'fiber': '8',
  },
];
