import 'package:flutter/material.dart';
import 'package:porsiku/constants/constants.dart'; // Ensure this path is correct

class CustomBottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.ramen_dining_outlined), // Chef hat icon for Recipes
          activeIcon: Icon(Icons.ramen_dining),
          label: 'Recipes',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.add_circle_outline,
            size: AppIcons.lg + 4,
          ), // Slightly larger Add icon
          activeIcon: Icon(Icons.add_circle, size: AppIcons.lg + 4),
          label: 'Add',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.insert_chart_outlined), // Analytics/Chart icon
          activeIcon: Icon(Icons.insert_chart),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz_outlined), // More icon
          activeIcon: Icon(Icons.more_horiz),
          label: 'More',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor:
          AppColors.blue, // Use AppColors (e.g. blue or a defined primary)
      unselectedItemColor: AppColors.grey, // Use AppColors
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      backgroundColor: AppColors.white,
      elevation: AppElevations.md, // Add some elevation
    );
  }
}
