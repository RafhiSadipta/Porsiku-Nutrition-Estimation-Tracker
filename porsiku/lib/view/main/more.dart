import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:porsiku/constants/constants.dart';
import 'package:porsiku/view/authentication/login.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AppAnimations.medium,
      vsync: this,
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    HapticFeedback.mediumImpact();

    // Show confirmation dialog
    final confirmed = await _showLogoutConfirmation();
    if (!confirmed) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Clear user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Show success message
      _showEnhancedMessage('Logged out successfully', isSuccess: true);

      // Navigate to login page
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          transitionDuration: AppAnimations.medium,
        ),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      _showEnhancedMessage('Logout failed: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<bool> _showLogoutConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  margin: EdgeInsets.all(AppSpacing.lg),
                  padding: EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                    boxShadow: AppShadows.floating,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.logout_rounded,
                          color: AppColors.error,
                          size: AppIcons.xl,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      Text(
                        'Logout Confirmation',
                        style: AppTextStyles.h3,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Are you sure you want to logout? You will need to login again to access your account.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppBorderRadius.md,
                                  ),
                                ),
                                side: BorderSide(color: AppColors.lightGrey),
                              ),
                              child: Text(
                                'Cancel',
                                style: AppTextStyles.buttonMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: AppColors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppBorderRadius.md,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Logout',
                                style: AppTextStyles.buttonMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
        ) ??
        false;
  }

  void _showEnhancedMessage(
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    Color backgroundColor;
    IconData icon;

    if (isError) {
      backgroundColor = AppColors.error;
      icon = Icons.error_rounded;
      HapticFeedback.heavyImpact();
    } else if (isSuccess) {
      backgroundColor = AppColors.success;
      icon = Icons.check_circle_rounded;
      HapticFeedback.lightImpact();
    } else {
      backgroundColor = AppColors.info;
      icon = Icons.info_rounded;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColors.white, size: AppIcons.sm),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        margin: EdgeInsets.all(AppSpacing.md),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              margin: EdgeInsets.all(AppSpacing.lg),
              padding: EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                boxShadow: AppShadows.floating,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.construction_rounded,
                      color: AppColors.primary,
                      size: AppIcons.xl,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'Coming Soon!',
                    style: AppTextStyles.h3,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    '$feature is currently under development. Stay tuned for updates!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppBorderRadius.md,
                          ),
                        ),
                      ),
                      child: Text('Okay', style: AppTextStyles.buttonLarge),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Menu Sections
            _buildMenuSection()
                .animate()
                .fadeIn(delay: 500.ms)
                .slideY(begin: 0.3),

            SizedBox(height: AppSpacing.xl),

            // Logout Button
            _buildLogoutSection()
                .animate()
                .fadeIn(delay: 700.ms)
                .slideY(begin: 0.3),

            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    final menuItems = [
      {
        'title': 'Account Settings',
        'items': [
          {
            'icon': Icons.person_outline_rounded,
            'title': 'Profile',
            'subtitle': 'Edit your personal information',
            'onTap': () => _showComingSoonDialog('Profile Settings'),
          },
          {
            'icon': Icons.security_rounded,
            'title': 'Privacy & Security',
            'subtitle': 'Control your privacy settings',
            'onTap': () => _showComingSoonDialog('Privacy Settings'),
          },
        ],
      },
      {
        'title': 'Save & Favorites',
        'items': [
          {
            'icon': Icons.bookmark_outline_rounded,
            'title': 'Saved Meals',
            'subtitle': 'View and manage your saved meals',
            'onTap': () => _showComingSoonDialog('Saved Meals'),
          },
          {
            'icon': Icons.favorite_outline_rounded,
            'title': 'Favorite Recipes',
            'subtitle': 'View and manage your favorite recipes',
            'onTap': () => _showComingSoonDialog('Favorite Recipes'),
          },
        ],
      },
      {
        'title': 'App Preferences',
        'items': [
          {
            'icon': Icons.fitness_center_rounded,
            'title': 'Fitness & Goals',
            'subtitle': 'Set your nutrition and fitness targets',
            'onTap': () => _showComingSoonDialog('Fitness & Goals'),
          },
          {
            'icon': Icons.dark_mode_outlined,
            'title': 'Appearance',
            'subtitle': 'Dark mode and theme preferences',
            'onTap': () => _showComingSoonDialog('Appearance Settings'),
          },
        ],
      },
    ];

    return Column(
      children:
          menuItems.map((section) {
            return Container(
              margin: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      section['title'] as String,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: AppTexts.semiBold,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      children:
                          (section['items'] as List<Map<String, dynamic>>)
                              .asMap()
                              .entries
                              .map((entry) {
                                final index = entry.key;
                                final item = entry.value;
                                final isLast =
                                    index ==
                                    (section['items']
                                                as List<Map<String, dynamic>>)
                                            .length -
                                        1;

                                return _buildMenuItem(
                                  icon: item['icon'] as IconData,
                                  title: item['title'] as String,
                                  subtitle: item['subtitle'] as String,
                                  onTap: item['onTap'] as VoidCallback,
                                  showDivider: !isLast,
                                );
                              })
                              .toList(),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: AppIcons.md,
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: AppTexts.medium,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: AppIcons.md,
                ),
              ],
            ),
            if (showDivider) ...[
              SizedBox(height: AppSpacing.lg),
              Divider(height: 1, color: AppColors.lightGrey, indent: 60),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppBorderRadius.md),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: AppIcons.lg),
            SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: AppTexts.medium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : _handleLogout,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            ),
            elevation: 0,
          ),
          icon:
              isLoading
                  ? SizedBox(
                    width: AppIcons.sm,
                    height: AppIcons.sm,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.white,
                      ),
                      strokeWidth: 2,
                    ),
                  )
                  : Icon(Icons.logout_rounded, size: AppIcons.sm),
          label: Text(
            isLoading ? 'Logging out...' : 'Logout',
            style: AppTextStyles.buttonLarge,
          ),
        ),
      ),
    );
  }
}
