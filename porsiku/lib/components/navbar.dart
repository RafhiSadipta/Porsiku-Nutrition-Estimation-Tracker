import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:porsiku/constants/constants.dart';

class CustomBottomNavbar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomBottomNavbar> createState() => _CustomBottomNavbarState();
}

class _CustomBottomNavbarState extends State<CustomBottomNavbar>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _slideAnimations;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();

    _slideAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: -4.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _handleTap(int index) {
    // Haptic feedback for better UX
    HapticFeedback.lightImpact();
    
    // Animate the tapped item
    _controllers[index].forward().then((_) {
      _controllers[index].reverse();
    });

    // Call the original callback
    widget.onItemTapped(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, -8),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          items: _buildNavItems(),
          currentIndex: widget.selectedIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.greyText,
          onTap: _handleTap,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          iconSize: 24,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
      ),
    )
        .animate()
        .slideY(
          begin: 1.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        )
        .fadeIn(
          duration: const Duration(milliseconds: 300),
        );
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    final items = [
      _NavItemData(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
        index: 0,
      ),
      _NavItemData(
        icon: Icons.restaurant_menu_outlined,
        activeIcon: Icons.restaurant_menu_rounded,
        label: 'Recipes',
        index: 1,
      ),
      _NavItemData(
        icon: Icons.add_circle_outline_rounded,
        activeIcon: Icons.add_circle_rounded,
        label: 'Add',
        index: 2,
        isAdd: true,
      ),
      _NavItemData(
        icon: Icons.analytics_outlined,
        activeIcon: Icons.analytics_rounded,
        label: 'Analytics',
        index: 3,
      ),
      _NavItemData(
        icon: Icons.more_horiz_rounded,
        activeIcon: Icons.more_horiz_rounded,
        label: 'More',
        index: 4,
      ),
    ];

    return items.map((item) => _buildNavItem(item)).toList();
  }

  BottomNavigationBarItem _buildNavItem(_NavItemData item) {
    final isSelected = widget.selectedIndex == item.index;
    
    return BottomNavigationBarItem(
      icon: AnimatedBuilder(
        animation: _scaleAnimations[item.index],
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimations[item.index].value),
            child: Transform.scale(
              scale: isSelected ? 1.1 : _scaleAnimations[item.index].value,
              child: _buildIconContainer(item, false),
            ),
          );
        },
      ),
      activeIcon: AnimatedBuilder(
        animation: _scaleAnimations[item.index],
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimations[item.index].value),
            child: Transform.scale(
              scale: _scaleAnimations[item.index].value,
              child: _buildIconContainer(item, true),
            ),
          );
        },
      ),
      label: item.label,
    );
  }

  Widget _buildIconContainer(_NavItemData item, bool isActive) {
    final isSelected = widget.selectedIndex == item.index;
    
    if (item.isAdd) {
      // Special styling for the Add button
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected 
              ? AppGradients.primary 
              : LinearGradient(
                  colors: [
                    AppColors.greyText.withOpacity(0.1),
                    AppColors.greyText.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Icon(
          isActive ? item.activeIcon : item.icon,
          size: 28,
          color: isSelected ? AppColors.white : AppColors.greyText,
        ),
      );
    }

    // Regular nav item
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected 
            ? AppColors.primary.withOpacity(0.1) 
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        border: isSelected ? Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ) : null,
      ),
      child: Icon(
        isActive ? item.activeIcon : item.icon,
        size: item.isAdd ? 28 : 24,
        color: isSelected ? AppColors.primary : null,
      ),
    )
        .animate(target: isSelected ? 1 : 0)
        .scaleXY(
          begin: 1.0,
          end: 1.05,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
        );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final bool isAdd;

  _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    this.isAdd = false,
  });
}

// Utility class for navbar animations and interactions
class NavbarAnimationPresets {
  static const Duration tapAnimation = Duration(milliseconds: 200);
  static const Duration slideAnimation = Duration(milliseconds: 400);
  static const Duration scaleAnimation = Duration(milliseconds: 150);
  
  static const Curve bounceInCurve = Curves.elasticOut;
  static const Curve slideInCurve = Curves.easeOutCubic;
  static const Curve tapCurve = Curves.easeOutBack;
}

// Badge widget for notifications (can be added to nav items)
class NavBadge extends StatelessWidget {
  final Widget child;
  final int? count;
  final bool showBadge;

  const NavBadge({
    super.key,
    required this.child,
    this.count,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBadge) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -6,
          top: -6,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: count != null
                ? Text(
                    count! > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  )
                : null,
          ),
        ),
      ],
    )
        .animate()
        .scale(
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
        )
        .fadeIn();
  }
}

// Enhanced version with floating Add button (optional alternative)
class CustomBottomNavbarWithFAB extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavbarWithFAB({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomBottomNavbarWithFAB> createState() => _CustomBottomNavbarWithFABState();
}

class _CustomBottomNavbarWithFABState extends State<CustomBottomNavbarWithFAB>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabRotationAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    _fabRotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Main navbar without Add button
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomNavigationBar(
              items: [
                _buildRegularNavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
                _buildRegularNavItem(Icons.restaurant_menu_outlined, Icons.restaurant_menu_rounded, 'Recipes'),
                const BottomNavigationBarItem(
                  icon: SizedBox(width: 48), // Placeholder for FAB
                  label: '',
                ),
                _buildRegularNavItem(Icons.analytics_outlined, Icons.analytics_rounded, 'Analytics'),
                _buildRegularNavItem(Icons.more_horiz_rounded, Icons.more_horiz_rounded, 'More'),
              ],
              currentIndex: widget.selectedIndex > 2 ? widget.selectedIndex : (widget.selectedIndex < 2 ? widget.selectedIndex : 0),
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.greyText,
              onTap: (index) {
                if (index >= 2) {
                  widget.onItemTapped(index + 1); // Adjust for missing Add button
                } else {
                  widget.onItemTapped(index);
                }
              },
              type: BottomNavigationBarType.fixed,
              showUnselectedLabels: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedFontSize: 12,
              unselectedFontSize: 11,
            ),
          ),
        ),

        // Floating Add Button
        Positioned(
          top: -25,
          child: AnimatedBuilder(
            animation: _fabController,
            builder: (context, child) {
              return Transform.scale(
                scale: _fabScaleAnimation.value,
                child: Transform.rotate(
                  angle: _fabRotationAnimation.value * 3.14159,
                  child: GestureDetector(
                    onTapDown: (_) => _fabController.forward(),
                    onTapUp: (_) => _fabController.reverse(),
                    onTapCancel: () => _fabController.reverse(),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      widget.onItemTapped(2);
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  BottomNavigationBarItem _buildRegularNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 24),
      activeIcon: Icon(activeIcon, size: 24),
      label: label,
    );
  }
}
