import 'package:flutter/material.dart';
import '../../constants/constants.dart';

class FilterRecipePage extends StatefulWidget {
  const FilterRecipePage({super.key});

  @override
  State<FilterRecipePage> createState() => _FilterRecipePageState();
}

class _FilterRecipePageState extends State<FilterRecipePage> {
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
    'Chicken Meat',
    'Cow Beef',
  ];

  // Meal types
  final List<String> mealTypes = [
    'Breakfast',
    'Brunch',
    'Lunch',
    'Dinner',
    'Beverages',
    'Appetizer',
  ];

  // Cook times
  final List<String> cookTimes = [
    'Under 10 min',
    'Under 20 min',
    'Under 30 min',
    'Under 1 hour',
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

  // Method untuk validasi input numerik
  bool _isNumeric(String? str) {
    if (str == null || str.isEmpty) return true;
    return double.tryParse(str) != null;
  }

  // Method untuk clear semua filter
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Filter Recipes',
          style: TextStyle(color: AppColors.black),
        ),
        actions: [
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text(
              'Clear All',
              style: TextStyle(color: AppColors.black),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search by Ingredients
            const Text(
              'Search by Ingredients',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  predefinedIngredients.map((ingredient) {
                    final isSelected = selectedIngredients.contains(ingredient);
                    return FilterChip(
                      label: Text(ingredient),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            selectedIngredients.add(ingredient);
                          } else {
                            selectedIngredients.remove(ingredient);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),

            // Add Custom Ingredient
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ingredientController,
                    decoration: InputDecoration(
                      hintText: 'Add Ingredient',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: _addIngredient,
                  ),
                ),
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
                        label: Text(ingredient),
                        onDeleted: () => _removeIngredient(ingredient),
                        backgroundColor: AppColors.white,
                      );
                    }).toList(),
              ),
            ],
            const SizedBox(height: 24),

            // Meal Type
            const Text(
              'Meal Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  mealTypes.map((type) {
                    final isSelected = selectedMealType == type;
                    return FilterChip(
                      label: Text(type),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          selectedMealType = selected ? type : '';
                        });
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),

            // Cook Time
            const Text(
              'Cook Time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  cookTimes.map((time) {
                    final isSelected = selectedCookTime == time;
                    return FilterChip(
                      label: Text(time),
                      selected: isSelected,
                      onSelected: (bool selected) {
                        setState(() {
                          selectedCookTime = selected ? time : '';
                        });
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),

            // Nutritional Ranges
            _buildNutritionalRange(
              'Calories Amount',
              _minCalories,
              _maxCalories,
              'cal',
            ),
            const SizedBox(height: 16),
            _buildNutritionalRange(
              'Protein Amount',
              _minProtein,
              _maxProtein,
              'gr',
            ),
            const SizedBox(height: 16),
            _buildNutritionalRange(
              'Carbohidrates Amount',
              _minCarbs,
              _maxCarbs,
              'gr',
            ),
            const SizedBox(height: 16),
            _buildNutritionalRange('Fats Amount', _minFats, _maxFats, 'gr'),
            const SizedBox(height: 24),

            // Updated Confirm Button dengan validasi
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
                        content: Text(
                          'Please enter valid numbers for nutritional values',
                        ),
                      ),
                    );
                    return;
                  }
                  final filterData = {
                    'ingredients': selectedIngredients,
                    'mealType': selectedMealType,
                    'cookTime': selectedCookTime,
                    'calories': {
                      'min':
                          _minCalories.text.isEmpty
                              ? null
                              : double.parse(_minCalories.text),
                      'max':
                          _maxCalories.text.isEmpty
                              ? null
                              : double.parse(_maxCalories.text),
                    },
                    'protein': {
                      'min':
                          _minProtein.text.isEmpty
                              ? null
                              : double.parse(_minProtein.text),
                      'max':
                          _maxProtein.text.isEmpty
                              ? null
                              : double.parse(_maxProtein.text),
                    },
                    'carbs': {
                      'min':
                          _minCarbs.text.isEmpty
                              ? null
                              : double.parse(_minCarbs.text),
                      'max':
                          _maxCarbs.text.isEmpty
                              ? null
                              : double.parse(_maxCarbs.text),
                    },
                    'fats': {
                      'min':
                          _minFats.text.isEmpty
                              ? null
                              : double.parse(_minFats.text),
                      'max':
                          _maxFats.text.isEmpty
                              ? null
                              : double.parse(_maxFats.text),
                    },
                  };
                  Navigator.pop(context, filterData);
                },
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionalRange(
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: minController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Min. amount',
                  suffixText: unit,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward),
            ),
            Expanded(
              child: TextField(
                controller: maxController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Max. amount',
                  suffixText: unit,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
