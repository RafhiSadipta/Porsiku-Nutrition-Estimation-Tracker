import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../service/api_service.dart';

class RecipeOpenPage extends StatefulWidget {
  final Map<String, dynamic> recipe;
  const RecipeOpenPage({super.key, required this.recipe});

  @override
  State<RecipeOpenPage> createState() => _RecipeOpenPageState();
}

class _RecipeOpenPageState extends State<RecipeOpenPage> {
  Map<String, dynamic>? recipeDetail;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchRecipeDetail();
  }

  Future<void> _fetchRecipeDetail() async {
    try {
      // Get recipe ID from the basic recipe data
      final recipeId = widget.recipe['id'] as int;
      final detail = await fetchRecipeDetail(recipeId);

      setState(() {
        recipeDetail = detail;
        isLoading = false;
      });
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
      body: SafeArea(
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Failed to load recipe details',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Go Back'),
                      ),
                    ],
                  ),
                )
                : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top image and app bar
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.lg,
                              ),
                              child: Image.network(
                                recipeDetail?['image'] ??
                                    widget.recipe['image'] ??
                                    '',
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 12,
                              left: 12,
                              child: _CircleButton(
                                icon: Icons.arrow_back,
                                onTap: () => Navigator.of(context).pop(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Title
                        Text(
                          recipeDetail?['title'] ??
                              widget.recipe['title'] ??
                              'Recipe',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.favorite_border,
                                label: 'Add to Favorite',
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.add,
                                label: 'Add Meal Log',
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16), // Meta info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: _MetaInfo(
                                icon: Icons.shopping_bag_outlined,
                                label:
                                    '${recipeDetail?['ingredients']?.length ?? widget.recipe['ingredients']?.length ?? 3} ingredients',
                              ),
                            ),
                            _Dot(),
                            Flexible(
                              child: _MetaInfo(
                                icon: Icons.timer_outlined,
                                label:
                                    '${recipeDetail?['readyInMinutes'] ?? widget.recipe['readyInMinutes'] ?? 45} minutes',
                              ),
                            ),
                            _Dot(),
                            Flexible(
                              child: _MetaInfo(
                                icon: Icons.people_outline,
                                label:
                                    '${recipeDetail?['servings'] ?? widget.recipe['servings'] ?? 8} servings',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Description
                        _DescriptionText(
                          recipeDetail?['summary'] ?? _dummyDescription,
                        ),
                        const SizedBox(height: 16), // Nutrition pills
                        Row(
                          children: [
                            Expanded(
                              child: _NutriPill(
                                icon: Icons.local_fire_department,
                                pillColor: const Color(0xFFEAF2FF),
                                iconBg: const Color(0xFF1976D2),
                                textColor: const Color(0xFF1976D2),
                                label:
                                    '${recipeDetail?['nutrition']?['calories']?.toInt() ?? (widget.recipe['calories'] as num?)?.toInt() ?? 120}cal',
                                title: 'Calories',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _NutriPill(
                                icon: Icons.fitness_center,
                                pillColor: const Color(0xFFFFEBEE),
                                iconBg: const Color(0xFFD32F2F),
                                textColor: const Color(0xFFD32F2F),
                                label:
                                    '${recipeDetail?['nutrition']?['protein']?.toInt() ?? (widget.recipe['protein'] as num?)?.toInt() ?? 21}g',
                                title: 'Protein',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _NutriPill(
                                icon: Icons.bakery_dining,
                                pillColor: const Color(0xFFFFF8E1),
                                iconBg: const Color(0xFFFFB300),
                                textColor: const Color(0xFFFFB300),
                                label:
                                    '${recipeDetail?['nutrition']?['carbohydrates']?.toInt() ?? (widget.recipe['carbs'] as num?)?.toInt() ?? 50}g',
                                title: 'Carbs',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _NutriPill(
                                icon: Icons.eco,
                                pillColor: const Color(0xFFE8F5E9),
                                iconBg: const Color(0xFF43A047),
                                textColor: const Color(0xFF43A047),
                                label:
                                    '${recipeDetail?['nutrition']?['fat']?.toInt() ?? (widget.recipe['fat'] as num?)?.toInt() ?? 8}g',
                                title: 'Fats',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Ingredients
                        _SectionCard(
                          title: 'Ingredients',
                          children: _buildIngredientsList(),
                        ),
                        const SizedBox(height: 16),
                        // Instructions
                        _SectionCard(
                          title: 'Instructions',
                          children: _buildInstructionsList(),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  List<Widget> _buildIngredientsList() {
    final ingredients = recipeDetail?['ingredients'] as List<dynamic>?;
    if (ingredients != null && ingredients.isNotEmpty) {
      return ingredients
          .map((ingredient) => _IngredientRow(text: ingredient.toString()))
          .toList();
    } else {
      return List.generate(
        3,
        (i) => _IngredientRow(text: _dummyIngredients[i]),
      );
    }
  }

  List<Widget> _buildInstructionsList() {
    final instructions = recipeDetail?['instructions'] as List<dynamic>?;
    if (instructions != null && instructions.isNotEmpty) {
      return instructions.asMap().entries.map((entry) {
        return _InstructionRow(
          number: entry.key + 1,
          text: entry.value.toString(),
        );
      }).toList();
    } else {
      return List.generate(
        4,
        (i) => _InstructionRow(number: i + 1, text: _dummyInstructions[i]),
      );
    }
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: AppColors.black, size: 20),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: AppColors.black, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          color: AppColors.black,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
    );
  }
}

class _MetaInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaInfo({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.grey, size: 16),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.grey,
              fontSize: 12, // Slightly smaller font
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: AppColors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _DescriptionText extends StatelessWidget {
  final String text;
  const _DescriptionText(this.text);

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
            style: TextStyle(
              color: AppColors.black,
              fontSize: 15,
              height: 1.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
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

class _NutriPill extends StatelessWidget {
  final IconData icon;
  final Color pillColor;
  final Color iconBg;
  final Color textColor;
  final String label;
  final String title;
  const _NutriPill({
    required this.icon,
    required this.pillColor,
    required this.iconBg,
    required this.textColor,
    required this.label,
    required this.title,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width:
              double
                  .infinity, // Make pill take full width of its Expanded parent
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ), // Reduce padding
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(12), // Smaller border radius
          ),
          child: Column(
            // Change to Column for vertical layout to save space
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16, // Smaller icon container
                height: 16,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 12,
                ), // Smaller icon
              ),
              const SizedBox(height: 4), // Space between icon and text
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12, // Smaller font
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 11, // Smaller font
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final String text;
  const _IngredientRow({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.add, size: 18, color: AppColors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.black, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  final int number;
  final String text;
  const _InstructionRow({required this.number, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(100),
            ),
            alignment: Alignment.center,
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.black,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Dummy data for preview
const _dummyDescription =
    'The recipe Scotch Eggs can be made in approximately 45 minutes. This recipe serves 8. One serving contains 296 calories, 17g of protein, and 20g of fat. For 83 cents per serving, this recipe covers 11% of your daily requirements of vitamins and minerals. It works well as a very reasonably priced hor d\'oeuvre. It is brought to you by Foodista. Head to the store and pick up bulk sausage, corn meal, eggs, and a few other things to make it today. 2 people were impressed by this recipe. It is a good option if you\'re following a dairy free diet. Overall, this recipe earns a not so awesome spoonacular score of 37%';
const List<String> _dummyIngredients = [
  '1 pound bulk sausage',
  '1 cup bread crumbs or corn meal',
  '9 eggs',
];
const List<String> _dummyInstructions = [
  'Divide sausage into 8 portions. On a lightly crumb sprinkled surface, pat out each portion to about 1/8 inch thickness.',
  'Wrap 1 sausage portion completely around 1 hard boiled egg, pressing edges together to seal. Repeat with remaining sausage and hard boiled eggs.',
  'Dip sausage-covered eggs in 1 beaten egg and then roll in breadcrumbs.',
  'Deep fry or place on baking sheet and bake in a 375 degree oven for 20 minutes until lightly browned.',
];
