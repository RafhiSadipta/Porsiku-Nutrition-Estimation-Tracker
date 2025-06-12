import 'dart:io';
import 'package:flutter/material.dart';
import 'package:porsiku/constants/constants.dart';
import 'package:porsiku/components/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResultPage extends StatefulWidget {
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
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String? konsumsiId;
  bool isDeleting = false;
  bool isLoading = true;
  late String foodName;

  @override
  void initState() {
    super.initState();
    final item =
        widget.nutritionResult.isNotEmpty ? widget.nutritionResult[0] : {};
    foodName = item['nama_makanan'] ?? 'Unknown Product';
    _logConsumption();
  }

  Future<void> _editFoodName() async {
    final controller = TextEditingController(text: foodName);
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Food Name'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Food Name'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('Save'),
              ),
            ],
          ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        foodName = result;
      });
      // Jika sudah ada konsumsiId, lakukan PUT ke backend
      if (konsumsiId != null) {
        await _updateFoodNameOnBackend();
      }
    }
  }

  Future<void> _updateFoodNameOnBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;
      final item =
          widget.nutritionResult.isNotEmpty ? widget.nutritionResult[0] : {};
      final Map<String, dynamic> nutr =
          item['nutrition_total'] ?? item['nutrition'] ?? item;
      final double totalKalori =
          (nutr['kalori'] ?? nutr['calories'] ?? 0).toDouble();
      final double totalKarbo =
          (nutr['karbohidrat'] ?? nutr['carbs'] ?? 0).toDouble();
      final double totalProtein = (nutr['protein'] ?? 0).toDouble();
      final double totalLemak = (nutr['lemak'] ?? nutr['fat'] ?? 0).toDouble();
      final now = DateTime.now();
      final mealType = 'Dinner';
      final jumlah = item['jumlah'] ?? (item['Jumlah'] ?? '');
      final Map<String, dynamic> nutritionItem = {
        'nama_makanan': foodName,
        'jumlah': jumlah,
        'kalori': totalKalori,
        'protein': totalProtein,
        'lemak': totalLemak,
        'karbohidrat': totalKarbo,
      };
      String foto = widget.imagePath;
      bool isFoto = widget.imagePath.isNotEmpty;
      final String? imageUrl = item['image_url'];
      if (!isFoto && imageUrl != null && imageUrl.isNotEmpty) {
        foto = imageUrl;
        isFoto = true;
      }
      final response = await http.put(
        Uri.parse('http://192.168.0.107:8080/api/konsumsi/$konsumsiId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nama_makanan': foodName,
          'kalori_total': totalKalori,
          'karbohidrat_total': totalKarbo,
          'protein_total': totalProtein,
          'lemak_total': totalLemak,
          'waktu_makan': mealType,
          'tanggal': now.toUtc().toIso8601String(),
          'is_foto': isFoto,
          'foto': foto,
          'nutrition_items': [nutritionItem],
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama makanan berhasil diupdate.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update nama makanan: ${response.body}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal update nama makanan: $e')));
    }
  }

  Future<void> _logConsumption() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final token = prefs.getString('token');
      if (userId == null || token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in.')));
        setState(() {
          isLoading = false;
        });
        return;
      }
      final item =
          widget.nutritionResult.isNotEmpty ? widget.nutritionResult[0] : {};
      final Map<String, dynamic> nutr =
          item['nutrition_total'] ?? item['nutrition'] ?? item;
      final double totalKalori =
          (nutr['kalori'] ?? nutr['calories'] ?? 0).toDouble();
      final double totalKarbo =
          (nutr['karbohidrat'] ?? nutr['carbs'] ?? 0).toDouble();
      final double totalProtein = (nutr['protein'] ?? 0).toDouble();
      final double totalLemak = (nutr['lemak'] ?? nutr['fat'] ?? 0).toDouble();
      final now = DateTime.now();
      final mealType =
          'Dinner'; // TODO: replace with actual selected meal type if needed
      final jumlah = item['jumlah'] ?? (item['Jumlah'] ?? '');
      final Map<String, dynamic> nutritionItem = {
        'nama_makanan': foodName,
        'jumlah': jumlah,
        'kalori': totalKalori,
        'protein': totalProtein,
        'lemak': totalLemak,
        'karbohidrat': totalKarbo,
      };
      // Foto logic: jika imagePath kosong dan imageUrl ada, simpan imageUrl ke foto dan is_foto true
      String foto = widget.imagePath;
      bool isFoto = widget.imagePath.isNotEmpty;
      final String? imageUrl = item['image_url'];
      if (!isFoto && imageUrl != null && imageUrl.isNotEmpty) {
        foto = imageUrl;
        isFoto = true;
      }
      final response = await http.post(
        Uri.parse('http://192.168.0.107:8080/api/konsumsi'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'id_user': userId,
          'nama_makanan': foodName,
          'kalori_total': totalKalori,
          'karbohidrat_total': totalKarbo,
          'protein_total': totalProtein,
          'lemak_total': totalLemak,
          'waktu_makan': mealType,
          'tanggal': now.toUtc().toIso8601String(),
          'is_foto': isFoto,
          'foto': foto,
          'nutrition_items': [nutritionItem],
        }),
      );
      if (response.statusCode == 200) {
        final resp = jsonDecode(response.body);
        setState(() {
          konsumsiId = resp['id_konsumsi']?.toString();
          isLoading = false;
        });
        // Jangan auto-pop, biarkan user menutup halaman secara manual
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal log konsumsi: ${response.body}')),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal log konsumsi: $e')));
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteConsumption() async {
    if (konsumsiId == null) return;
    setState(() {
      isDeleting = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in.')));
        setState(() {
          isDeleting = false;
        });
        return;
      }
      final response = await http.put(
        Uri.parse('http://192.168.0.107:8080/api/konsumsi/$konsumsiId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'soft_deleted': true}),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Konsumsi berhasil dihapus.')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal hapus konsumsi: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal hapus konsumsi: $e')));
    }
    setState(() {
      isDeleting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> item =
        widget.nutritionResult.isNotEmpty ? widget.nutritionResult[0] : {};
    final String foodName = item['nama_makanan'] ?? 'Unknown Product';
    final String foodImage =
        widget.imagePath.isNotEmpty
            ? widget.imagePath
            : 'assets/images/Rename.png';
    final String? imageUrl = item['image_url'];
    final String mealType = 'Dinner';
    final int quantity = 1;
    final Map<String, dynamic> nutr =
        item['nutrition_total'] ?? item['nutrition'] ?? item;
    final double totalKalori =
        (nutr['kalori'] ?? nutr['calories'] ?? 0).toDouble();
    final double totalKarbo =
        (nutr['karbohidrat'] ?? nutr['carbs'] ?? 0).toDouble();
    final double totalProtein = (nutr['protein'] ?? 0).toDouble();
    final double totalLemak = (nutr['lemak'] ?? nutr['fat'] ?? 0).toDouble();
    final Map<String, dynamic> nutrition = {
      'calories': totalKalori.round(),
      'carbs': totalKarbo.round(),
      'proteins': totalProtein.round(),
      'fats': totalLemak.round(),
    };
    // Tampilkan warning jika semua nutrisi 0
    final bool isNutritionZero = nutrition.values.every((v) => v == 0);
    final List<Map<String, dynamic>> ingredients =
        widget.nutritionResult.isNotEmpty
            ? widget.nutritionResult.map<Map<String, dynamic>>((item) {
              final nutr = item['nutrition_total'] ?? {};
              return {
                'name': item['nama_makanan'] ?? '',
                'kalori': (nutr['kalori'] ?? 0).round(),
                'jumlah': item['jumlah'] ?? '',
              };
            }).toList()
            : [
              {'name': 'Nasi', 'kalori': 270, 'jumlah': '150g'},
              {'name': 'Ayam Pop', 'kalori': 270, 'jumlah': '150g'},
              {'name': 'Sambal', 'kalori': 270, 'jumlah': '150g'},
            ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: AppColors.black),
            onPressed: () {},
            tooltip: 'Save',
          ),
          IconButton(
            icon:
                isDeleting
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.delete_outline, color: AppColors.red),
            onPressed: isDeleting ? null : _deleteConsumption,
            tooltip: 'Remove',
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(AppBorderRadius.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isNutritionZero)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.yellow[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Nutrisi tidak ditemukan untuk produk ini. Data akan tetap disimpan, namun nilai nutrisi 0.',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                    // Gambar makanan
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      child:
                          widget.imagePath.isNotEmpty
                              ? Image.file(
                                File(foodImage),
                                width: double.infinity,
                                height: 180,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        Image.asset('assets/images/Rename.png'),
                              )
                              : (imageUrl != null
                                  ? Image.network(
                                    imageUrl,
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                              'assets/images/Rename.png',
                                            ),
                                  )
                                  : Image.asset(
                                    'assets/images/Rename.png',
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  )),
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
                          onPressed: _editFoodName,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppBorderRadius.md),
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
                          const SizedBox(width: AppBorderRadius.md),
                          DropdownButton<String>(
                            value: mealType,
                            underline: const SizedBox(),
                            items:
                                ['Breakfast', 'Lunch', 'Dinner']
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) {},
                          ),
                          const SizedBox(width: AppBorderRadius.md),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  size: AppIcons.md,
                                ),
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
                          value: nutrition['proteins'],
                          label: 'Protein',
                          color: AppColors.red,
                        ),
                        _NutritionCard(
                          icon: Icons.eco,
                          value: nutrition['fats'],
                          label: 'Fat',
                          color: AppColors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppBorderRadius.md),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              '${ing['kalori']} cal\u00A0\u00A0${ing['jumlah']}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.red,
                              ),
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
                    ),
                    // Pada bagian bawah sebelum akhir Column, tambahkan tombol Selesai jika log sukses
                    if (!isLoading && konsumsiId != null)
                      Button(
                        text: 'Selesai',
                        variant: ButtonVariant.primary,
                        onPressed: () {
                          Navigator.of(context).pop('refresh');
                        },
                      ),
                  ],
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
            '$value${label == 'kalori' ? '' : 'g'}',
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
