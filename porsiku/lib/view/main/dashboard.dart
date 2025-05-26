import 'package:flutter/material.dart';
import 'package:porsiku/components/button.dart';
import 'package:porsiku/constants/constants.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:porsiku/components/section_card.dart';
import 'package:porsiku/components/navbar.dart';
import 'package:porsiku/components/calories_progress_indicator.dart';
import 'package:porsiku/components/nutrient_progress_row.dart';
import 'package:porsiku/components/recommendation_carousel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:porsiku/service/api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final CarouselSliderController
  _carouselController = // Ensure this type matches RecommendationCarousel
      CarouselSliderController();
  int _currentCarouselIndex = 0; // Tambahkan state untuk indeks carousel
  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<Map<String, dynamic>>? _futureDailyTarget;

  @override
  void initState() {
    super.initState();
    _initDailyTarget();
  }

  void _initDailyTarget() async {
    final userId = await _getUserId();
    if (userId != null) {
      setState(() {
        _futureDailyTarget = fetchDailyTarget(userId);
      });
    }
  }

  void _onItemTapped(int index) {
    // If the 'Add' button is tapped, show the dialog
    if (index == 2) {
      _showAddOptionsDialog(context);
    } else {
      // For other items, update the selected index and navigate
      setState(() {
        _selectedIndex = index;
      });
      if (index == 0) {
        // Navigate to Home (already on dashboard, so do nothing or refresh)
      } else if (index == 1) {
        // Navigate to Recipes Page by name
        // Navigator.pushNamed(context, '/recipes'); // Assuming you have a recipes page
      } else if (index == 3) {
        // Navigate to Analytics Page by name
        // Navigator.pushNamed(context, '/analytics');
      } else if (index == 4) {
        // Navigate to More/Profile Page by name
        // Navigator.pushNamed(context, '/profile');
      }
    }
  }

  void _showAddOptionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.lg),
        ),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(
            AppBorderRadius.lg,
          ), // Changed from AppPadding.lg
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Add Food Entry",
                style: TextStyle(
                  fontSize: AppTexts.lg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(
                height: AppBorderRadius.md,
              ), // Changed from AppPadding.md
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _buildDialogOption(
                    context,
                    icon: Icons.camera_alt_outlined,
                    label: "Camera",
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to Camera/Scan page
                      Navigator.pushNamed(context, '/scan');
                    },
                  ),
                  _buildDialogOption(
                    context,
                    icon: Icons.text_fields_outlined,
                    label: "Text",
                    onTap: () {
                      Navigator.pop(context); // Close the options dialog first
                      _showTextInputDialog(
                        context,
                      ); // Then show the text input dialog
                    },
                  ),
                  _buildDialogOption(
                    context,
                    icon: Icons.mic_none_outlined,
                    label: "Voice",
                    onTap: () {
                      Navigator.pop(context); // Close the options dialog first
                      _showVoiceInputDialog(
                        context,
                      ); // Then show the voice input dialog
                    },
                  ),
                  _buildDialogOption(
                    context,
                    icon: Icons.bookmark_border_outlined,
                    label: "Saved",
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to Saved Meals page
                      // Navigator.pushNamed(context, '/saved-meals');
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: AppBorderRadius.md,
              ), // Changed from AppPadding.md
            ],
          ),
        );
      },
    );
  }

  void _showTextInputDialog(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppBorderRadius.lg,
            ), // Consistent rounding
          ),
          backgroundColor: AppColors.white,
          contentPadding: const EdgeInsets.all(AppBorderRadius.lg),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.grey),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              TextField(
                controller: textController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "What do you eat today?",
                  hintStyle: TextStyle(color: AppColors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    borderSide: BorderSide(color: AppColors.lightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    borderSide: BorderSide(
                      color: AppColors.blue,
                    ), // Highlight color when focused
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppBorderRadius.md,
                    vertical: AppBorderRadius.sm, // Adjust vertical padding
                  ),
                ),
              ),
              const SizedBox(height: AppBorderRadius.lg),
              Button(
                text: "Confirm",
                variant: ButtonVariant.primary,
                onPressed: () {
                  // TODO: Implement what happens on confirm (e.g., process textController.text)
                  print("Food entered: ${textController.text}");
                  Navigator.of(context).pop(); // Close the text input dialog
                },
                // Make button full width or adjust as needed
                // minWidth: double.infinity,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVoiceInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          ),
          backgroundColor: AppColors.white,
          contentPadding: const EdgeInsets.all(AppBorderRadius.lg),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "What do you eat today?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppTexts.lg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: AppBorderRadius.sm / 2),
              Text(
                "Speak loud and clear",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: AppTexts.md, color: AppColors.grey),
              ),
              const SizedBox(
                height: AppBorderRadius.lg + AppBorderRadius.md,
              ), // Adjusted gap before icon
              Container(
                padding: const EdgeInsets.all(
                  AppBorderRadius.lg,
                ), // Padding around the icon
                decoration: BoxDecoration(
                  color: AppColors.black, // Black background for the circle
                  shape: BoxShape.circle, // Circular shape
                ),
                child: Icon(
                  Icons.mic,
                  size: AppIcons.xl + AppIcons.md, // Larger icon size
                  color: AppColors.white, // White icon color
                ),
              ),
              const SizedBox(height: AppBorderRadius.lg),
              // Optionally, add a button to close or confirm, though the image doesn't show one.
              // For now, tapping outside the dialog will close it.
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.md),
      child: Padding(
        padding: const EdgeInsets.all(
          AppBorderRadius.sm,
        ), // Changed from AppPadding.sm
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(
                AppBorderRadius.md,
              ), // Changed from AppPadding.md
              decoration: BoxDecoration(
                color: AppColors.lightGrey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(
                  AppBorderRadius.lg,
                ), // Changed from AppBorderRadius.xl to AppBorderRadius.lg
              ),
              child: Icon(
                icon,
                size: AppIcons.xl,
                color: AppColors.blue,
              ), // Changed from AppColors.primary to AppColors.blue
            ),
            const SizedBox(
              height: AppBorderRadius.sm / 2,
            ), // Changed from AppPadding.xs to AppBorderRadius.sm / 2 for smaller gap
            Text(
              label,
              style: TextStyle(
                fontSize: AppTexts.sm,
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: AppElevations.none,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.black),
          onPressed: () {
            // TODO: Implement drawer opening or other menu action
            // Scaffold.of(context).openDrawer();
          },
        ),
        title: Text(
          'PorsiKu',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: AppTexts.lg, // Ensure consistent text size
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: AppColors.black, // Use AppColors
            ),
            onPressed: () {
              // TODO: Implement notification functionality
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboardContent(),
          // Placeholder for Recipes Page (index 1 in new setup)
          // Container(child: Center(child: Text("Recipes Page"))),
          // Placeholder for Scan/Add action (index 2) - might not be a page
          Container(), // This corresponds to index 2, which is 'Add'
          // Placeholder for Analytics Page (index 3)
          // Container(child: Center(child: Text("Analytics Page"))),
          // Placeholder for More/Profile Page (index 4)
          // Container(child: Center(child: Text("More/Profile Page"))),
        ],
      ),
      bottomNavigationBar: CustomBottomNavbar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildDashboardContent() {
    if (_futureDailyTarget == null) {
      return const Center(
        child: Text('User ID tidak ditemukan. Silakan login ulang.'),
      );
    }
    return FutureBuilder<Map<String, dynamic>>(
      future: _futureDailyTarget,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: \\${snapshot.error}'));
        }
        final data = snapshot.data ?? {};
        final String userName = "Abyan"; // Ganti dengan data user jika ada
        final Map<String, dynamic> todayGoal = {
          'calories': {'current': 0, 'target': data['kalori_harian'] ?? 2000},
          'protein': {'current': 0, 'target': data['protein_harian'] ?? 50},
          'fat': {'current': 0, 'target': data['lemak_harian'] ?? 50},
          'carbs': {'current': 0, 'target': data['karbo_harian'] ?? 180},
        };

        final List<Map<String, dynamic>> recommendations = [
          {
            'image':
                'assets/images/Rename.png', // Placeholder, replace with actual image path
            'title': 'Telur Dadar Elite',
            'calories': 120,
            'protein': 21,
            'carbs': 50, // Assuming this is carbs based on image
            'fat': 8,
            'time': '8min',
          },
          {
            'image': 'assets/images/Rename.png', // Placeholder
            'title': 'Healthy Salad',
            'calories': 350,
            'protein': 15,
            'carbs': 30,
            'fat': 20,
            'time': '10min',
          },
        ];

        final List<Map<String, dynamic>> recentActivity = [
          {
            'title': 'Nasi Padang',
            'calories': 270,
            'mass': '150g',
            'image': 'assets/images/Rename.png', // Placeholder
          },
          {
            'title': 'Declan Rice',
            'calories': 270, // Assuming this is a food item, if not, adjust
            'mass': '1 serving',
            'image':
                'assets/images/Rename.png', // Placeholder, ensure it's a food image
          },
        ];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppBorderRadius.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Pagi, $userName!',
                style: TextStyle(
                  fontSize: AppTexts.xl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: AppBorderRadius.sm / 2),
              Text(
                'Track your progress and stay healthy.',
                style: TextStyle(
                  fontSize: AppTexts.md,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: AppBorderRadius.lg),
              SectionCard(
                title: "Today's Goal",
                contentChild: _buildTodayGoalContent(todayGoal),
              ),
              const SizedBox(height: AppBorderRadius.lg),
              SectionCard(
                title: "Breakfast Recommendation",
                contentChild: _buildRecommendationContent(recommendations),
              ),
              const SizedBox(height: AppBorderRadius.lg),
              SectionCard(
                title: "Recent Activity",
                contentChild: _buildRecentActivityContent(recentActivity),
              ),
              const SizedBox(height: AppBorderRadius.lg),
              Button(
                text: "Scan Makanan",
                variant: ButtonVariant.primary, // Added variant
                onPressed: () {
                  _onItemTapped(2); // Assuming index 2 is for scan/add
                },
              ),
              const SizedBox(height: AppBorderRadius.sm),
              Button(
                text: "Lihat Detail Gizi",
                variant: ButtonVariant.secondary, // Added variant
                onPressed: () {
                  // TODO: Implement navigation to nutrition details
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodayGoalContent(Map<String, dynamic> todayGoal) {
    // Pastikan semua value dikonversi ke double
    double toDouble(dynamic value) {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: CaloriesProgressIndicator(
            currentCalories: toDouble(todayGoal['calories']['current']).toInt(),
            targetCalories: toDouble(todayGoal['calories']['target']).toInt(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NutrientProgressRow(
                title: 'Protein',
                currentValue: toDouble(todayGoal['protein']['current']).toInt(),
                targetValue: toDouble(todayGoal['protein']['target']).toInt(),
                progressColor: AppColors.red,
              ),
              const SizedBox(height: 8),
              NutrientProgressRow(
                title: 'Fat',
                currentValue: toDouble(todayGoal['fat']['current']).toInt(),
                targetValue: toDouble(todayGoal['fat']['target']).toInt(),
                progressColor: AppColors.green,
              ),
              const SizedBox(height: 8),
              NutrientProgressRow(
                title: 'Carbs',
                currentValue: toDouble(todayGoal['carbs']['current']).toInt(),
                targetValue: toDouble(todayGoal['carbs']['target']).toInt(),
                progressColor: AppColors.yellow,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationContent(
    List<Map<String, dynamic>> recommendations,
  ) {
    return RecommendationCarousel(
      recommendations: recommendations,
      carouselController: _carouselController,
      currentCarouselIndex: _currentCarouselIndex,
      onPageChanged: (index, reason) {
        setState(() {
          _currentCarouselIndex = index;
        });
      },
    );
  }

  Widget _buildRecentActivityContent(
    List<Map<String, dynamic>> recentActivity,
  ) {
    if (recentActivity.isEmpty) {
      return const SizedBox.shrink();
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentActivity.length,
      itemBuilder: (context, index) {
        final activity = recentActivity[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(
              AppBorderRadius.sm,
            ), // Rounded image corners
            child: Image.asset(
              activity['image']! as String,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            activity['title']! as String,
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text('${activity['calories']} cal, ${activity['mass']}'),
          trailing: IconButton(
            icon: Icon(Icons.close, color: AppColors.grey, size: AppTexts.lg),
            onPressed: () {
              // TODO: Implement delete recent activity
              setState(() {
                // This is a placeholder for actual deletion logic
                // For example, if recentActivity is a state variable:
                // recentActivity.removeAt(index);
              });
            },
          ),
          contentPadding:
              EdgeInsets
                  .zero, // Remove default ListTile padding if SectionCard handles it
        );
      },
      separatorBuilder:
          (context, index) =>
              const Divider(height: 1, indent: 66), // Add a divider with indent
    );
  }
}
