import 'package:flutter/material.dart';
import '../constants/constants.dart';

class FilterRecipeDialog extends StatefulWidget {
  const FilterRecipeDialog({super.key});

  @override
  State<FilterRecipeDialog> createState() => _FilterRecipeDialogState();
}

class _FilterRecipeDialogState extends State<FilterRecipeDialog> {
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

  // Predefined ingredients examples
  final List<String> predefinedIngredients = [
    'Egg',
    'Tomato',
    'Milk',
    'Rice',
    'Banana',
    'Chicken',
    'Beef',
  ];

  // Meal types
  final List<String> mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

  // Cook times
  final List<String> cookTimes = [
    'Under 15 min',
    'Under 30 min',
    'Under 1 hour',
    'Over 1 hour',
  ];

  void _addIngredient() {
    if (_ingredientController.text.isNotEmpty &&
        !selectedIngredients.contains(_ingredientController.text)) {
      setState(() {
        selectedIngredients.add(_ingredientController.text);
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      selectedIngredients.remove(ingredient);
    });
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
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Filter Recipes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearAllFilters,
                    child: const Text(
                      'Clear All',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ingredients Section
                    _buildSectionTitle('Ingredients'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          predefinedIngredients.map((ingredient) {
                            final isSelected = selectedIngredients.contains(
                              ingredient,
                            );
                            return _buildFilterChip(ingredient, isSelected, (
                              selected,
                            ) {
                              setState(() {
                                if (selected) {
                                  selectedIngredients.add(ingredient);
                                } else {
                                  selectedIngredients.remove(ingredient);
                                }
                              });
                            });
                          }).toList(),
                    ),
                    const SizedBox(height: 12),

                    // Add Custom Ingredient
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _ingredientController,
                            hintText: 'Add ingredient',
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildAddButton(_addIngredient),
                      ],
                    ),
                    if (selectedIngredients.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            selectedIngredients.map((ingredient) {
                              return Chip(
                                label: Text(
                                  ingredient,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                onDeleted: () => _removeIngredient(ingredient),
                                backgroundColor: AppColors.white,
                                deleteIconColor: AppColors.grey,
                              );
                            }).toList(),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Meal Type Section
                    _buildSectionTitle('Meal Type'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          mealTypes.map((type) {
                            final isSelected = selectedMealType == type;
                            return _buildFilterChip(type, isSelected, (
                              selected,
                            ) {
                              setState(() {
                                selectedMealType = selected ? type : '';
                              });
                            });
                          }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Cook Time Section
                    _buildSectionTitle('Cook Time'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          cookTimes.map((time) {
                            final isSelected = selectedCookTime == time;
                            return _buildFilterChip(time, isSelected, (
                              selected,
                            ) {
                              setState(() {
                                selectedCookTime = selected ? time : '';
                              });
                            });
                          }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Nutrition Ranges
                    _buildNutritionRange(
                      'Calories',
                      _minCalories,
                      _maxCalories,
                      'cal',
                    ),
                    const SizedBox(height: 12),
                    _buildNutritionRange(
                      'Protein',
                      _minProtein,
                      _maxProtein,
                      'g',
                    ),
                    const SizedBox(height: 12),
                    _buildNutritionRange('Carbs', _minCarbs, _maxCarbs, 'g'),
                    const SizedBox(height: 12),
                    _buildNutritionRange('Fats', _minFats, _maxFats, 'g'),
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_isNumeric(_minCalories.text) ||
                            !_isNumeric(_maxCalories.text) ||
                            !_isNumeric(_minProtein.text) ||
                            !_isNumeric(_maxProtein.text) ||
                            !_isNumeric(_minCarbs.text) ||
                            !_isNumeric(_maxCarbs.text) ||
                            !_isNumeric(_minFats.text) ||
                            !_isNumeric(_maxFats.text)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter valid numbers'),
                            ),
                          );
                          return;
                        } // Map UI fields to Spoonacular API parameters
                        final filterData = <String, dynamic>{};

                        // Include ingredients (comma-separated string)
                        if (selectedIngredients.isNotEmpty) {
                          filterData['includeIngredients'] = selectedIngredients
                              .join(',');
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
                            case 'Under 1 hour':
                              maxReadyTime = 60;
                              break;
                            case 'Over 1 hour':
                              maxReadyTime =
                                  120; // Set a reasonable upper limit
                              break;
                          }
                          if (maxReadyTime != null) {
                            filterData['maxReadyTime'] = maxReadyTime;
                          }
                        }

                        // Nutrition parameters (map exactly to Spoonacular API)
                        if (_minCalories.text.isNotEmpty) {
                          filterData['minCalories'] = double.parse(
                            _minCalories.text,
                          );
                        }
                        if (_maxCalories.text.isNotEmpty) {
                          filterData['maxCalories'] = double.parse(
                            _maxCalories.text,
                          );
                        }
                        if (_minProtein.text.isNotEmpty) {
                          filterData['minProtein'] = double.parse(
                            _minProtein.text,
                          );
                        }
                        if (_maxProtein.text.isNotEmpty) {
                          filterData['maxProtein'] = double.parse(
                            _maxProtein.text,
                          );
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
                        Navigator.of(context).pop(filterData);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    Function(bool) onSelected,
  ) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : AppColors.grey,
        ),
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: AppColors.white,
      selectedColor: AppColors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? AppColors.black : AppColors.grey),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    String? suffixText,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 40,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 12, color: AppColors.grey),
          suffixText: suffixText,
          suffixStyle: const TextStyle(fontSize: 12, color: AppColors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.black),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildNutritionRange(
    String title,
    TextEditingController minController,
    TextEditingController maxController,
    String unit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: minController,
                hintText: 'Min',
                suffixText: unit,
                keyboardType: TextInputType.number,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward, size: 16, color: AppColors.grey),
            ),
            Expanded(
              child: _buildTextField(
                controller: maxController,
                hintText: 'Max',
                suffixText: unit,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
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
}
