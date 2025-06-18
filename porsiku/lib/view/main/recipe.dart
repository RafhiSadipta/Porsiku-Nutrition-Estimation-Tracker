import 'package:flutter/material.dart';
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
                      onPressed: () async {
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
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Search bar
                  Expanded(
                    child: _SearchBar(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (errorMsg != null)
                Center(child: Text(errorMsg!))
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: Column(
                      children: [
                        Expanded(
                          child: GridView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  childAspectRatio:
                                      0.75, // Increase aspect ratio to give more height
                                ),
                            itemCount: recipes.length,
                            itemBuilder: (context, index) {
                              final recipe = recipes[index];
                              return RecipeCard(recipe: recipe);
                            },
                          ),
                        ),
                        if (isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          )
                        else if (!hasMoreData && recipes.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No more recipes to load',
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
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
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

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
              controller: controller,
              onChanged: (_) => onChanged(),
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
            padding: const EdgeInsets.only(
              top: 4,
              left: 4,
              right: 4,
              bottom: 8,
            ),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 140, // Reduce image height
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        image: DecorationImage(
                          image: NetworkImage(recipe['image'] ?? ''),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8, // Reduce top position
                      left: 8, // Reduce left position
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer,
                              color: AppColors.white,
                              size: 12,
                            ), // Reduce icon size
                            const SizedBox(width: 2), // Reduce spacing
                            Text(
                              recipe['readyInMinutes'] != null
                                  ? '${recipe['readyInMinutes']} min'
                                  : '-',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 9, // Reduce font size
                                fontWeight: FontWeight.w700,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8, // Reduce top position
                      right: 8, // Reduce right position
                      child: Container(
                        width: 28, // Reduce button size
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.sm,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            (recipe['isBookmarked'] is bool &&
                                    recipe['isBookmarked'] == true)
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: AppColors.white,
                            size: 16, // Reduce icon size
                          ),
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Reduce spacing
                Expanded(
                  // Use Expanded for title to prevent overflow
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      recipe['title'] ?? '-',
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 12, // Reduce font size
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 4), // Reduce spacing
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Wrap(
                    spacing: 2, // Reduce spacing
                    runSpacing: 2, // Reduce spacing
                    children: [
                      _NutriPill(
                        icon: Icons.local_fire_department,
                        pillColor: const Color(0xFFEFF6FF),
                        iconBg: const Color(0xFF155DFC),
                        textColor: const Color(0xFF155DFC),
                        label:
                            '${(recipe['calories'] as num?)?.toInt() ?? 0}cal',
                      ),
                      _NutriPill(
                        icon: Icons.fitness_center,
                        pillColor: const Color(0xFFFEF2F2),
                        iconBg: const Color(0xFFE7000B),
                        textColor: const Color(0xFFE7000B),
                        label: '${(recipe['protein'] as num?)?.toInt() ?? 0}g',
                      ),
                      _NutriPill(
                        icon: Icons.bubble_chart,
                        pillColor: const Color(0xFFFFFCE2),
                        iconBg: const Color(0xFFD08700),
                        textColor: const Color(0xFFD08700),
                        label: '${(recipe['carbs'] as num?)?.toInt() ?? 0}g',
                      ),
                      _NutriPill(
                        icon: Icons.eco,
                        pillColor: const Color(0xFFF0FDF4),
                        iconBg: const Color(0xFF00A63E),
                        textColor: const Color(0xFF00A63E),
                        label: '${(recipe['fat'] as num?)?.toInt() ?? 0}g',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4), // Add small bottom spacing
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
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 2,
        ), // More compact padding
        decoration: BoxDecoration(
          color: pillColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14, // Smaller icon container
              height: 14,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(icon, color: Colors.white, size: 10), // Smaller icon
            ),
            const SizedBox(width: 2),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 8, // Smaller font
                fontWeight: FontWeight.w500,
                height: 1.0, // Tighter line height
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
