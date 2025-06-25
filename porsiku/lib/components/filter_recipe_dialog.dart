import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';

class FilterRecipeBottomSheet extends StatefulWidget {
  const FilterRecipeBottomSheet({super.key});

  @override
  State<FilterRecipeBottomSheet> createState() =>
      _FilterRecipeBottomSheetState();

  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => const FilterRecipeBottomSheet(),
    );
  }
}

class _FilterRecipeBottomSheetState extends State<FilterRecipeBottomSheet>
    with TickerProviderStateMixin {
  final TextEditingController _ingredientController = TextEditingController();
  List<String> selectedIngredients = [];
  String selectedMealType = '';
  String selectedCookTime = '';

  final TextEditingController _minCalories = TextEditingController();
  final TextEditingController _maxCalories = TextEditingController();
  final TextEditingController _minProtein = TextEditingController();
  final TextEditingController _maxProtein = TextEditingController();
  final TextEditingController _minCarbs = TextEditingController();
  final TextEditingController _maxCarbs = TextEditingController();
  final TextEditingController _minFats = TextEditingController();
  final TextEditingController _maxFats = TextEditingController();

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Predefined ingredients examples
  final List<String> predefinedIngredients = [
    'Egg',
    'Tomato',
    'Milk',
    'Rice',
    'Banana',
    'Chicken',
    'Beef',
    'Cheese',
    'Onion',
    'Garlic',
  ];

  // Meal types with icons
  final List<Map<String, dynamic>> mealTypes = [
    {'name': 'Breakfast', 'icon': Icons.wb_sunny_rounded},
    {'name': 'Lunch', 'icon': Icons.lunch_dining_rounded},
    {'name': 'Dinner', 'icon': Icons.dinner_dining_rounded},
    {'name': 'Snack', 'icon': Icons.fastfood_rounded},
  ];

  // Cook times with icons
  final List<Map<String, dynamic>> cookTimes = [
    {'name': "Under 15'", 'icon': Icons.flash_on_rounded},
    {'name': "Under 30'", 'icon': Icons.schedule_rounded},
    {'name': "Under 60'", 'icon': Icons.access_time_rounded},
    {'name': "Over 60'", 'icon': Icons.more_time_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _ingredientController.dispose();
    _minCalories.dispose();
    _maxCalories.dispose();
    _minProtein.dispose();
    _maxProtein.dispose();
    _minCarbs.dispose();
    _maxCarbs.dispose();
    _minFats.dispose();
    _maxFats.dispose();
    super.dispose();
  }

  void _addIngredient() {
    if (_ingredientController.text.isNotEmpty &&
        !selectedIngredients.contains(_ingredientController.text)) {
      setState(() {
        selectedIngredients.add(_ingredientController.text);
        _ingredientController.clear();
      });
      HapticFeedback.lightImpact();
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      selectedIngredients.remove(ingredient);
    });
    HapticFeedback.lightImpact();
  }

  bool _isNumeric(String? str) {
    if (str == null || str.isEmpty) return true;
    return double.tryParse(str) != null;
  }

  void _clearAllFilters() {
    setState(() {
      selectedIngredients.clear();
      selectedMealType = '';
      selectedCookTime = '';
      _minCalories.clear();
      _maxCalories.clear();
      _minProtein.clear();
      _maxProtein.clear();
      _minCarbs.clear();
      _maxCarbs.clear();
      _minFats.clear();
      _maxFats.clear();
    });
    HapticFeedback.mediumImpact();
  }

  bool get _hasActiveFilters {
    return selectedIngredients.isNotEmpty ||
        selectedMealType.isNotEmpty ||
        selectedCookTime.isNotEmpty ||
        _minCalories.text.isNotEmpty ||
        _maxCalories.text.isNotEmpty ||
        _minProtein.text.isNotEmpty ||
        _maxProtein.text.isNotEmpty ||
        _minCarbs.text.isNotEmpty ||
        _maxCarbs.text.isNotEmpty ||
        _minFats.text.isNotEmpty ||
        _maxFats.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppBorderRadius.xl),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                      margin: EdgeInsets.only(top: AppSpacing.sm),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(AppBorderRadius.xs),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .scaleX(
                      begin: 0.5,
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),

                // Content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(
                        AppSpacing.md,
                      ), // Reduced from lg to md
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ingredients Section
                          _buildIngredientsSection()
                              .animate()
                              .fadeIn(delay: 400.ms)
                              .slideY(
                                begin: 0.3,
                                duration: 600.ms,
                                curve: Curves.easeOutCubic,
                              ),

                          SizedBox(
                            height: AppSpacing.lg,
                          ), // Reduced from xl to lg
                          // Meal Type Section
                          _buildMealTypeSection()
                              .animate()
                              .fadeIn(delay: 600.ms)
                              .slideY(
                                begin: 0.3,
                                duration: 600.ms,
                                curve: Curves.easeOutCubic,
                              ),

                          SizedBox(
                            height: AppSpacing.lg,
                          ), // Reduced from xl to lg
                          // Cook Time Section
                          _buildCookTimeSection()
                              .animate()
                              .fadeIn(delay: 800.ms)
                              .slideY(
                                begin: 0.3,
                                duration: 600.ms,
                                curve: Curves.easeOutCubic,
                              ),
                          SizedBox(
                            height: AppSpacing.lg,
                          ), // Reduced from xl to lg
                          // Nutrition Section
                          _buildNutritionSection()
                              .animate()
                              .fadeIn(delay: 1000.ms)
                              .slideY(
                                begin: 0.3,
                                duration: 600.ms,
                                curve: Curves.easeOutCubic,
                              ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer
                _buildFooter()
                    .animate()
                    .fadeIn(delay: 400.ms)
                    .slideY(
                      begin: 0.5,
                      duration: 600.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredientsSection() {
    return _SectionCard(
      title: 'Ingredients',
      subtitle: 'Add ingredients you want to include',
      icon: Icons.restaurant_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Predefined ingredients
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children:
                predefinedIngredients.asMap().entries.map((entry) {
                  final ingredient = entry.value;
                  final index = entry.key;
                  final isSelected = selectedIngredients.contains(ingredient);

                  return _FilterChip(
                    label: ingredient,
                    isSelected: isSelected,
                    index: index,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          selectedIngredients.add(ingredient);
                        } else {
                          selectedIngredients.remove(ingredient);
                        }
                      });
                      HapticFeedback.lightImpact();
                    },
                  );
                }).toList(),
          ),

          SizedBox(height: AppSpacing.md), // Reduced from lg to md
          // Add custom ingredient
          Row(
            children: [
              Expanded(
                child: _TextField(
                  controller: _ingredientController,
                  hintText: 'Add custom ingredient...',
                  prefixIcon: Icons.add_rounded,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              _AddButton(onPressed: _addIngredient),
            ],
          ),

          // Selected custom ingredients
          if (selectedIngredients
              .where(
                (ingredient) => !predefinedIngredients.contains(ingredient),
              )
              .isNotEmpty) ...[
            SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children:
                  selectedIngredients
                      .where(
                        (ingredient) =>
                            !predefinedIngredients.contains(ingredient),
                      )
                      .map(
                        (ingredient) => _SelectedIngredientChip(
                          ingredient: ingredient,
                          onRemove: () => _removeIngredient(ingredient),
                        ),
                      )
                      .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealTypeSection() {
    return _SectionCard(
      title: 'Meal Type',
      subtitle: 'Choose when you want to enjoy this recipe',
      icon: Icons.restaurant_menu_rounded,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 2.5,
        children:
            mealTypes.asMap().entries.map((entry) {
              final mealType = entry.value;
              final index = entry.key;
              final isSelected = selectedMealType == mealType['name'];

              return _MealTypeCard(
                name: mealType['name'],
                icon: mealType['icon'],
                isSelected: isSelected,
                index: index,
                onTap: () {
                  setState(() {
                    selectedMealType = isSelected ? '' : mealType['name'];
                  });
                  HapticFeedback.lightImpact();
                },
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCookTimeSection() {
    return _SectionCard(
      title: 'Cook Time',
      subtitle: 'How much time do you have?',
      icon: Icons.schedule_rounded,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 2.5,
        children:
            cookTimes.asMap().entries.map((entry) {
              final cookTime = entry.value;
              final index = entry.key;
              final isSelected = selectedCookTime == cookTime['name'];

              return _CookTimeCard(
                name: cookTime['name'],
                icon: cookTime['icon'],
                isSelected: isSelected,
                index: index,
                onTap: () {
                  setState(() {
                    selectedCookTime = isSelected ? '' : cookTime['name'];
                  });
                  HapticFeedback.lightImpact();
                },
              );
            }).toList(),
      ),
    );
  }

  Widget _buildNutritionSection() {
    return _SectionCard(
      title: 'Nutrition Range',
      subtitle: 'Set your preferred nutrition values',
      icon: Icons.local_fire_department_rounded,
      child: Column(
        children: [
          _buildNutritionRange(
            'Calories',
            _minCalories,
            _maxCalories,
            'kcal',
            Icons.local_fire_department_rounded,
            AppColors.blue,
          ),
          SizedBox(height: AppSpacing.md), // Reduced from lg to md
          _buildNutritionRange(
            'Protein',
            _minProtein,
            _maxProtein,
            'g',
            Icons.fitness_center_rounded,
            const Color(0xFFE7000B),
          ),
          SizedBox(height: AppSpacing.md), // Reduced from lg to md
          _buildNutritionRange(
            'Carbs',
            _minCarbs,
            _maxCarbs,
            'g',
            Icons.bakery_dining_rounded,
            AppColors.warning,
          ),
          SizedBox(height: AppSpacing.md), // Reduced from lg to md
          _buildNutritionRange(
            'Fats',
            _minFats,
            _maxFats,
            'g',
            Icons.eco_rounded,
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md), // Reduced from lg to md
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppBorderRadius.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_hasActiveFilters)
            _Button(
              text: 'Clear All',
              onPressed: _clearAllFilters,
              isOutlined: true,
              icon: Icons.clear_all_rounded,
            )
          else
            _Button(
              text: 'Close',
              onPressed: () => Navigator.of(context).pop(),
              isOutlined: true,
              icon: Icons.close_rounded,
            ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: _Button(
              text:
                  _hasActiveFilters
                      ? 'Apply ${_getActiveFiltersCount()} Filters'
                      : 'Apply Filters',
              onPressed: _applyFilters,
              icon: Icons.check_rounded,
            ),
          ),
        ],
      ),
    );
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (selectedIngredients.isNotEmpty) count++;
    if (selectedMealType.isNotEmpty) count++;
    if (selectedCookTime.isNotEmpty) count++;
    if (_minCalories.text.isNotEmpty || _maxCalories.text.isNotEmpty) count++;
    if (_minProtein.text.isNotEmpty || _maxProtein.text.isNotEmpty) count++;
    if (_minCarbs.text.isNotEmpty || _maxCarbs.text.isNotEmpty) count++;
    if (_minFats.text.isNotEmpty || _maxFats.text.isNotEmpty) count++;
    return count;
  }

  void _applyFilters() {
    if (!_isNumeric(_minCalories.text) ||
        !_isNumeric(_maxCalories.text) ||
        !_isNumeric(_minProtein.text) ||
        !_isNumeric(_maxProtein.text) ||
        !_isNumeric(_minCarbs.text) ||
        !_isNumeric(_maxCarbs.text) ||
        !_isNumeric(_minFats.text) ||
        !_isNumeric(_maxFats.text)) {
      _showErrorSnackBar('Please enter valid numbers for nutrition values');
      return;
    }

    // Map UI fields to Spoonacular API parameters
    final filterData = <String, dynamic>{};

    // Include ingredients (comma-separated string)
    if (selectedIngredients.isNotEmpty) {
      filterData['includeIngredients'] = selectedIngredients.join(',');
    }

    // Meal type maps to 'type' parameter
    if (selectedMealType.isNotEmpty) {
      filterData['type'] = selectedMealType.toLowerCase();
    }

    // Cook time maps to maxReadyTime in minutes
    if (selectedCookTime.isNotEmpty) {
      int? maxReadyTime;
      switch (selectedCookTime) {
        case 'Under 15 min':
          maxReadyTime = 15;
          break;
        case 'Under 30 min':
          maxReadyTime = 30;
          break;
        case 'Under 60 min':
          maxReadyTime = 60;
          break;
        case 'Over 60 min':
          maxReadyTime = 600;
          break;
      }
      if (maxReadyTime != null) {
        filterData['maxReadyTime'] = maxReadyTime;
      }
    }

    // Nutrition parameters
    if (_minCalories.text.isNotEmpty) {
      filterData['minCalories'] = double.parse(_minCalories.text);
    }
    if (_maxCalories.text.isNotEmpty) {
      filterData['maxCalories'] = double.parse(_maxCalories.text);
    }
    if (_minProtein.text.isNotEmpty) {
      filterData['minProtein'] = double.parse(_minProtein.text);
    }
    if (_maxProtein.text.isNotEmpty) {
      filterData['maxProtein'] = double.parse(_maxProtein.text);
    }
    if (_minCarbs.text.isNotEmpty) {
      filterData['minCarbs'] = double.parse(_minCarbs.text);
    }
    if (_maxCarbs.text.isNotEmpty) {
      filterData['maxCarbs'] = double.parse(_maxCarbs.text);
    }
    if (_minFats.text.isNotEmpty) {
      filterData['minFat'] = double.parse(_minFats.text);
    }
    if (_maxFats.text.isNotEmpty) {
      filterData['maxFat'] = double.parse(_maxFats.text);
    }

    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(filterData);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.white),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(AppSpacing.lg),
      ),
    );
  }
}

//  Component Classes
class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md), // Reduced from lg to md
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
              Container(
                padding: EdgeInsets.all(AppSpacing.xs), // Reduced from sm to xs
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Icon(
                  icon,
                  color: AppColors.white,
                  size: 16,
                ), // Reduced from 18 to 16
              ),
              SizedBox(width: AppSpacing.md), // Reduced from md to sm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md), // Reduced from lg to md
          child,
        ],
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final int index;
  final Function(bool) onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.index,
    required this.onSelected,
  });

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip>
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
              child: FilterChip(
                label: Text(
                  widget.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color:
                        widget.isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                selected: widget.isSelected,
                onSelected: (selected) {
                  widget.onSelected(selected);
                },
                backgroundColor:
                    AppColors
                        .white, // Changed from AppColors.lightGrey.withOpacity(0.3) to white
                selectedColor: AppColors.primary,
                checkmarkColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                  side: BorderSide(
                    color:
                        widget.isSelected
                            ? AppColors.primary
                            : AppColors.lightGrey,
                    width: 1.5,
                  ),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            );
          },
        )
        .animate()
        .fadeIn(
          duration: Duration(milliseconds: 300),
          delay: Duration(milliseconds: widget.index * 100),
        )
        .slideX(
          begin: 0.3,
          duration: Duration(milliseconds: 400),
          delay: Duration(milliseconds: widget.index * 100),
          curve: Curves.easeOutCubic,
        );
  }
}

class _TextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final String? suffixText;
  final TextInputType? keyboardType;

  const _TextField({
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixText,
    this.keyboardType,
  });

  @override
  State<_TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  bool _isFocused = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          48, // Increased from 44 to 48 for better vertical centering with suffixText
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: Border.all(
          color: _isFocused ? AppColors.primary : AppColors.lightGrey,
          width: 1.5,
        ),
        boxShadow:
            _isFocused
                ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
                : [],
      ),
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        textAlignVertical: TextAlignVertical.center,
        onTap: () {
          setState(() => _isFocused = true);
          HapticFeedback.selectionClick();
        },
        onTapOutside: (_) => setState(() => _isFocused = false),
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon:
              widget.prefixIcon != null
                  ? Icon(
                    widget.prefixIcon,
                    color:
                        _isFocused
                            ? AppColors.primary
                            : AppColors.textSecondary,
                    size: 20,
                  )
                  : null,
          suffixText: widget.suffixText,
          suffixStyle: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical:
                AppSpacing
                    .sm, // Changed back to AppSpacing.sm for better alignment with suffixText
          ),
          isDense: false, // Changed to false to allow proper vertical centering
        ),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AddButton({required this.onPressed});

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton>
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
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
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                onTap: widget.onPressed,
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                child: Icon(
                  Icons.add_rounded,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SelectedIngredientChip extends StatelessWidget {
  final String ingredient;
  final VoidCallback onRemove;

  const _SelectedIngredientChip({
    required this.ingredient,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
          label: Text(
            ingredient,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          onDeleted: onRemove,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          deleteIconColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withOpacity(0.3), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .scaleXY(begin: 0.8, duration: 400.ms, curve: Curves.elasticOut);
  }
}

class _MealTypeCard extends StatefulWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final int index;
  final VoidCallback onTap;

  const _MealTypeCard({
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.index,
    required this.onTap,
  });

  @override
  State<_MealTypeCard> createState() => _MealTypeCardState();
}

class _MealTypeCardState extends State<_MealTypeCard>
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
              child: GestureDetector(
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: widget.isSelected ? AppGradients.primary : null,
                    color:
                        widget.isSelected
                            ? null
                            : AppColors.lightGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(
                      color:
                          widget.isSelected
                              ? AppColors.primary
                              : AppColors.lightGrey.withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow:
                        widget.isSelected
                            ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                            : [],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.icon,
                        color:
                            widget.isSelected
                                ? AppColors.white
                                : AppColors.textSecondary,
                        size: 20,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          widget.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color:
                                widget.isSelected
                                    ? AppColors.white
                                    : AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        )
        .animate()
        .fadeIn(
          duration: Duration(milliseconds: 300),
          delay: Duration(milliseconds: widget.index * 100),
        )
        .slideY(
          begin: 0.3,
          duration: Duration(milliseconds: 400),
          delay: Duration(milliseconds: widget.index * 100),
          curve: Curves.easeOutCubic,
        );
  }
}

class _CookTimeCard extends StatefulWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final int index;
  final VoidCallback onTap;

  const _CookTimeCard({
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.index,
    required this.onTap,
  });

  @override
  State<_CookTimeCard> createState() => _CookTimeCardState();
}

class _CookTimeCardState extends State<_CookTimeCard>
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
              child: GestureDetector(
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                onTap: widget.onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: widget.isSelected ? AppGradients.primary : null,
                    color:
                        widget.isSelected
                            ? null
                            : AppColors.lightGrey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(
                      color:
                          widget.isSelected
                              ? AppColors.primary
                              : AppColors.lightGrey.withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow:
                        widget.isSelected
                            ? [
                              BoxShadow(
                                color: AppColors.secondary.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                            : [],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.icon,
                        color:
                            widget.isSelected
                                ? AppColors.white
                                : AppColors.textSecondary,
                        size: 20,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          widget.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color:
                                widget.isSelected
                                    ? AppColors.white
                                    : AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        )
        .animate()
        .fadeIn(
          duration: Duration(milliseconds: 300),
          delay: Duration(milliseconds: widget.index * 100),
        )
        .slideY(
          begin: 0.3,
          duration: Duration(milliseconds: 400),
          delay: Duration(milliseconds: widget.index * 100),
          curve: Curves.easeOutCubic,
        );
  }
}

class _Button extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final IconData? icon;

  const _Button({
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.icon,
  });

  @override
  State<_Button> createState() => _ButtonState();
}

class _ButtonState extends State<_Button> with SingleTickerProviderStateMixin {
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
            height: 48,
            decoration: BoxDecoration(
              gradient: widget.isOutlined ? null : AppGradients.primary,
              color: widget.isOutlined ? AppColors.white : null,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              border:
                  widget.isOutlined
                      ? Border.all(color: AppColors.lightGrey, width: 1.5)
                      : null,
              boxShadow:
                  widget.isOutlined
                      ? []
                      : [
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
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                onTap: widget.onPressed,
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color:
                              widget.isOutlined
                                  ? AppColors.textPrimary
                                  : AppColors.white,
                          size: 18,
                        ),
                        SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        widget.text,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color:
                              widget.isOutlined
                                  ? AppColors.textPrimary
                                  : AppColors.white,
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

Widget _buildNutritionRange(
  String title,
  TextEditingController minController,
  TextEditingController maxController,
  String unit,
  IconData icon,
  Color color,
) {
  return Container(
    padding: EdgeInsets.all(AppSpacing.sm), // Reduced from md to sm
    decoration: BoxDecoration(
      color: AppColors.lightGrey.withOpacity(0.3),
      borderRadius: BorderRadius.circular(AppBorderRadius.md),
      border: Border.all(color: AppColors.lightGrey.withOpacity(0.5), width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(4), // Reduced from 6 to 4
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppBorderRadius.xs),
                border: Border.all(color: color.withOpacity(0.2), width: 1),
              ),
              child: Icon(
                icon,
                color: color,
                size: 14,
              ), // Reduced from 16 to 14
            ),
            SizedBox(width: AppSpacing.xs), // Reduced from sm to xs
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm), // Reduced from md to sm
        Row(
          children: [
            Expanded(
              child: _TextField(
                controller: minController,
                hintText: 'Min',
                suffixText: unit,
                keyboardType: TextInputType.number,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
              ), // Reduced from sm to xs
              padding: EdgeInsets.all(4), // Reduced from 6 to 4
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.xs),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 14, // Reduced from 16 to 14
                color: AppColors.textSecondary,
              ),
            ),
            Expanded(
              child: _TextField(
                controller: maxController,
                hintText: 'Max',
                suffixText: unit,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
