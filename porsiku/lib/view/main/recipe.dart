import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import 'recipe_open.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // Tambahkan SafeArea di sini
        child: Padding(
          padding: const EdgeInsets.all(16), // Ubah padding ke 16 di semua sisi
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Filter button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      boxShadow: AppShadows.card,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.filter_list,
                        color: AppColors.grey,
                        size: 24,
                      ),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Search bar
                  Expanded(child: _SearchBar()),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: _dummyRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _dummyRecipes[index];
                    return RecipeCard(recipe: recipe);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search Recipe',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              style: const TextStyle(fontSize: AppTexts.md),
            ),
          ),
          const Icon(Icons.search, color: AppColors.grey, size: 22),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;
  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RecipeOpenPage(recipe: recipe),
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth,
            // Kurangi padding bawah agar tidak overflow
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4, bottom: 8),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Card height hug content
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        image: DecorationImage(
                          image: NetworkImage(recipe['image']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer, color: AppColors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              recipe['duration'],
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                        ),
                        child: IconButton(
                          icon: Icon(
                            recipe['isBookmarked']
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: AppColors.white,
                            size: 18,
                          ),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      recipe['title'],
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: AppTexts.sm,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Container(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        _NutriPill(
                          icon: Icons.local_fire_department,
                          pillColor: const Color(0xFFEFF6FF),
                          iconBg: const Color(0xFF155DFC),
                          textColor: const Color(0xFF155DFC),
                          label: '${recipe['calories']}cal',
                        ),
                        _NutriPill(
                          icon: Icons.fitness_center,
                          pillColor: const Color(0xFFFEF2F2),
                          iconBg: const Color(0xFFE7000B),
                          textColor: const Color(0xFFE7000B),
                          label: '${recipe['protein']}g',
                        ),
                        _NutriPill(
                          icon: Icons.bubble_chart,
                          pillColor: const Color(0xFFFFFCE2),
                          iconBg: const Color(0xFFD08700),
                          textColor: const Color(0xFFD08700),
                          label: '${recipe['weight']}g',
                        ),
                        _NutriPill(
                          icon: Icons.eco,
                          pillColor: const Color(0xFFF0FDF4),
                          iconBg: const Color(0xFF00A63E),
                          textColor: const Color(0xFF00A63E),
                          label: '${recipe['fiber']}g',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NutriPill extends StatelessWidget {
  final IconData icon;
  final Color pillColor;
  final Color iconBg;
  final Color textColor;
  final String label;
  const _NutriPill({
    required this.icon,
    required this.pillColor,
    required this.iconBg,
    required this.textColor,
    required this.label,
  });
  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.only(top: 1, left: 4, right: 8, bottom: 1),
        decoration: BoxDecoration(
          color: pillColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(icon, color: Colors.white, size: 12),
            ),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy data untuk preview UI
defaultImage() =>
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&h=180&q=80';
final List<Map<String, dynamic>> _dummyRecipes = [
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
