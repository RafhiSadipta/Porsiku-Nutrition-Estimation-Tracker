import 'dart:io';
import 'package:flutter/material.dart';
import 'package:porsiku/constants/constants.dart';
import 'package:porsiku/components/button.dart';

class ResultPage extends StatelessWidget {
  final String foodListText;
  final List nutritionResult;
  final String imagePath;
  const ResultPage({
    super.key,
    required this.foodListText,
    required this.nutritionResult,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    // Gunakan nutritionResult dan imagePath jika tersedia, fallback ke dummy jika null
    final String foodName =
        nutritionResult.isNotEmpty
            ? nutritionResult[0]['nama_makanan'] ?? 'Food'
            : 'Nasi Padang';
    final String foodImage =
        imagePath.isNotEmpty ? imagePath : 'assets/images/Rename.png';
    final double price = 19.47; // Dummy, bisa dihilangkan atau diganti
    final String mealType = 'Dinner';
    final int quantity = 1;
    // Hitung total nutrisi
    double totalKalori = 0, totalKarbo = 0, totalProtein = 0, totalLemak = 0;
    for (final item in nutritionResult) {
      totalKalori += (item['kalori'] ?? 0).toDouble();
      totalKarbo += (item['karbohidrat'] ?? 0).toDouble();
      totalProtein += (item['protein'] ?? 0).toDouble();
      totalLemak += (item['lemak'] ?? 0).toDouble();
    }
    final Map<String, dynamic> nutrition = {
      'calories': totalKalori.round(),
      'carbs': totalKarbo.round(),
      'protein': totalProtein.round(),
      'fat': totalLemak.round(),
    };
    final List<Map<String, dynamic>> ingredients =
        nutritionResult.isNotEmpty
            ? nutritionResult
                .map<Map<String, dynamic>>(
                  (item) => {
                    'name': item['nama_makanan'] ?? '',
                    'calories': (item['kalori'] ?? 0).round(),
                    'mass': item['jumlah'] ?? '',
                  },
                )
                .toList()
            : [
              {'name': 'Nasi', 'calories': 270, 'mass': '150g'},
              {'name': 'Ayam Pop', 'calories': 270, 'mass': '150g'},
              {'name': 'Sambal', 'calories': 270, 'mass': '150g'},
            ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: null,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: AppColors.black),
            onPressed: () {},
            tooltip: 'Save',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.red),
            onPressed: () {},
            tooltip: 'Remove',
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppBorderRadius.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food Image & Title
              ClipRRect(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                child: Image.file(
                  File(foodImage),
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Image.asset(
                        'assets/images/Rename.png',
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                ),
              ),
              const SizedBox(height: AppBorderRadius.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      foodName,
                      style: TextStyle(
                        fontSize: AppTexts.lg,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      size: AppIcons.md,
                      color: AppColors.grey,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: AppBorderRadius.md),
              // Price, Meal Type, Quantity
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppBorderRadius.md,
                  vertical: AppBorderRadius.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        price.toStringAsFixed(2),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: AppTexts.md,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppBorderRadius.md),
                    DropdownButton<String>(
                      value: mealType,
                      underline: const SizedBox(),
                      items:
                          ['Breakfast', 'Lunch', 'Dinner']
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (v) {},
                    ),
                    const SizedBox(width: AppBorderRadius.md),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: AppIcons.md),
                          onPressed: () {},
                        ),
                        Text(
                          '$quantity',
                          style: TextStyle(fontSize: AppTexts.md),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: AppIcons.md),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppBorderRadius.md),
              // Nutrition Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NutritionCard(
                    icon: Icons.local_fire_department,
                    value: nutrition['calories'],
                    label: 'Calories',
                    color: AppColors.blue,
                  ),
                  _NutritionCard(
                    icon: Icons.bubble_chart,
                    value: nutrition['carbs'],
                    label: 'Carbs',
                    color: AppColors.yellow,
                  ),
                  _NutritionCard(
                    icon: Icons.fitness_center,
                    value: nutrition['protein'],
                    label: 'Protein',
                    color: AppColors.red,
                  ),
                  _NutritionCard(
                    icon: Icons.eco,
                    value: nutrition['fat'],
                    label: 'Fat',
                    color: AppColors.green,
                  ),
                ],
              ),
              const SizedBox(height: AppBorderRadius.md),
              // Ingredients List
              Text(
                'Ingredients',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppTexts.md,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: AppBorderRadius.sm),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ingredients.length,
                  separatorBuilder:
                      (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final ing = ingredients[index];
                    return ListTile(
                      title: Text(
                        ing['name'],
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '${ing['calories']} cal\u00A0\u00A0${ing['mass']}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: AppColors.red),
                        onPressed: () {},
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppBorderRadius.lg),
              Button(
                text: '+ Add Ingredients',
                variant: ButtonVariant.primary,
                onPressed: () {},
                // Make button full width
                // minWidth: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color color;
  const _NutritionCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: AppIcons.lg),
          const SizedBox(height: 4),
          Text(
            '$value${label == 'Calories' ? '' : 'g'}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppTexts.md,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: AppTexts.sm, color: AppColors.darkGrey),
          ),
        ],
      ),
    );
  }
}
