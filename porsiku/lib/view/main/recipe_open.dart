import 'package:flutter/material.dart';
import '../../constants/constants.dart';

class RecipeOpenPage extends StatelessWidget {
  final Map<String, dynamic> recipe;
  const RecipeOpenPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top image and app bar
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      child: Image.network(
                        recipe['image'],
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
                    Positioned(
                      top: 12,
                      right: 56,
                      child: _CircleButton(
                        icon: Icons.favorite_border,
                        onTap: () {},
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _CircleButton(icon: Icons.add, onTap: () {}),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  recipe['title'],
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
                const SizedBox(height: 16),
                // Meta info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MetaInfo(
                      icon: Icons.shopping_bag_outlined,
                      label:
                          '${recipe['ingredients']?.length ?? 3} ingredients',
                    ),
                    _Dot(),
                    _MetaInfo(
                      icon: Icons.timer_outlined,
                      label: recipe['duration'] ?? '45 minutes',
                    ),
                    _Dot(),
                    _MetaInfo(
                      icon: Icons.people_outline,
                      label: '${recipe['servings'] ?? 8} servings',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Description
                _DescriptionText(recipe['description'] ?? _dummyDescription),
                const SizedBox(height: 16),
                // Nutrition pills
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NutriPill(
                      icon: Icons.local_fire_department,
                      pillColor: const Color(0xFFEAF2FF),
                      iconBg: const Color(0xFF1976D2),
                      textColor: const Color(0xFF1976D2),
                      label: '${recipe['calories'] ?? '120'}cal',
                      title: 'Calories',
                    ),
                    _NutriPill(
                      icon: Icons.fitness_center,
                      pillColor: const Color(0xFFFFEBEE),
                      iconBg: const Color(0xFFD32F2F),
                      textColor: const Color(0xFFD32F2F),
                      label: '${recipe['protein'] ?? '21'}g',
                      title: 'Protein',
                    ),
                    _NutriPill(
                      icon: Icons.bakery_dining,
                      pillColor: const Color(0xFFFFF8E1),
                      iconBg: const Color(0xFFFFB300),
                      textColor: const Color(0xFFFFB300),
                      label: '${recipe['carbs'] ?? '500'}g',
                      title: 'Carbs',
                    ),
                    _NutriPill(
                      icon: Icons.eco,
                      pillColor: const Color(0xFFE8F5E9),
                      iconBg: const Color(0xFF43A047),
                      textColor: const Color(0xFF43A047),
                      label: '${recipe['fats'] ?? '8'}g',
                      title: 'Fats',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Ingredients
                _SectionCard(
                  title: 'Ingredients',
                  children: List.generate(
                    (recipe['ingredients']?.length ?? 3),
                    (i) => _IngredientRow(
                      text: recipe['ingredients']?[i] ?? _dummyIngredients[i],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Instructions
                _SectionCard(
                  title: 'Instructions',
                  children: List.generate(
                    (recipe['instructions']?.length ?? 4),
                    (i) => _InstructionRow(
                      number: i + 1,
                      text: recipe['instructions']?[i] ?? _dummyInstructions[i],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
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
      children: [
        Icon(icon, color: AppColors.grey, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
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
  @override
  Widget build(BuildContext context) {
    // For demo, just use normal text. For bold/colored, use RichText if needed.
    return Text(
      text,
      style: const TextStyle(color: AppColors.black, fontSize: 15, height: 1.5),
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
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
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
            fontSize: 13,
          ),
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
