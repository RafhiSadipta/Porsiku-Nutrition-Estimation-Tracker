import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppIcons {
  static double get xs => 16.sp;
  static double get sm => 20.sp;
  static double get md => 24.sp;
  static double get lg => 30.sp;
  static double get xl => 48.sp;
}

class AppTexts {
  // Font Sizes - Using ScreenUtil for responsive text
  static double get xs => 12.sp;
  static double get sm => 14.sp;
  static double get md => 16.sp;
  static double get ml => 18.sp;
  static double get lg => 20.sp;
  static double get xl => 24.sp;
  static double get xxl => 32.sp;
  static double get xxxl => 48.sp;

  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
}

class AppBorderRadius {
  static double get xs => 4.r;
  static double get sm => 8.r;
  static double get md => 12.r;
  static double get lg => 16.r;
  static double get xl => 20.r;
  static double get xxl => 24.r;
  static double get infinity => 100.r;
}

class AppColors {
  // Primary Colors - Orange theme from icon
  static const Color primary = Color(0xFFFF6B35); // Main orange
  static const Color primaryLight = Color(0xFFFF8A5B); // Lighter orange
  static const Color primaryDark = Color(0xFFE55A2B); // Darker orange
  static const Color primarySurface = Color(
    0xFFFFF4F0,
  ); // Very light orange for backgrounds

  // Secondary Colors
  static const Color secondary = Color(0xFF4F4F4F);
  static const Color accent = Color(0xFFFFC107);

  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA); // Slightly warmer white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0B1215);
  static const Color white = Color(0xFFFFFFFF);

  // Grey Scale
  static const Color grey = Color(0xFFABADB0);
  static const Color lightGrey = Color(0xFFE8E8E8);
  static const Color darkGrey = Color(0xFF707173);
  static const Color greyText = Color(0xFF6B7280);

  // Status Colors
  static const Color success = Color(0xFF10B981); // Modern green
  static const Color error = Color(0xFFEF4444); // Modern red
  static const Color warning = Color(0xFFF59E0B); // Modern yellow
  static const Color info = Color(0xFF3B82F6); // Modern blue

  // Legacy colors (keeping for backward compatibility)
  static const Color red = Color(0xFFFF6D61);
  static const Color green = Color(0xFF91D15F);
  static const Color blue = Color(0xFF41ADFB);
  static const Color yellow = Color(0xFFECBC00);

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
}

// Gradients
class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryVertical = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient primaryHorizontal = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient subtle = LinearGradient(
    colors: [AppColors.primarySurface, AppColors.background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient success = LinearGradient(
    colors: [AppColors.success, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warning = LinearGradient(
    colors: [AppColors.warning, Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppElevations {
  static const double none = 0;
  static const double sm = 2;
  static const double md = 6;
  static const double lg = 12;
}

class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> smButton = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.12),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> lgCard = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.15),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> primaryButton = [
    BoxShadow(
      color: AppColors.primary.withOpacity(0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
}

// Spacing Constants - Using ScreenUtil for responsive spacing
class AppSpacing {
  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 16.w;
  static double get lg => 24.w;
  static double get xl => 32.w;
  static double get xxl => 48.w;
  static double get xxxl => 64.w;
}

// Animation Constants
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // Animation Curves
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeIn = Curves.easeIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
}

// Animation Presets for UI Libraries
class AppAnimationPresets {
  // Shimmer Settings
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF9FAFB);

  // Flutter Animate Presets
  static const Duration slideInDuration = Duration(milliseconds: 300);
  static const Duration fadeInDuration = Duration(milliseconds: 400);
  static const Duration scaleInDuration = Duration(milliseconds: 250);

  // Lottie Settings
  static const double lottieSmall = 80;
  static const double lottieMedium = 120;
  static const double lottieLarge = 200;
}

// Breakpoints for Responsive Design
class AppBreakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;
}

// Z-Index for Layer Management
class AppZIndex {
  static const int background = 0;
  static const int content = 1;
  static const int overlay = 10;
  static const int modal = 100;
  static const int tooltip = 1000;
  static const int toast = 10000;
}

// Button Constants - Using ScreenUtil for responsive buttons
class AppButtons {
  static double get height => 48.h;
  static double get heightSmall => 36.h;
  static double get heightLarge => 56.h;
  static EdgeInsets get padding =>
      EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h);
  static EdgeInsets get paddingSmall =>
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h);
  static EdgeInsets get paddingLarge =>
      EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h);
}

// Card Constants - Using ScreenUtil for responsive cards
class AppCards {
  static EdgeInsets get padding => EdgeInsets.all(16.w);
  static EdgeInsets get paddingSmall => EdgeInsets.all(12.w);
  static EdgeInsets get paddingLarge => EdgeInsets.all(24.w);
  static double get borderWidth => 1.w;
}

// Input Field Constants - Using ScreenUtil for responsive inputs
class AppInputs {
  static double get height => 48.h;
  static EdgeInsets get padding =>
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h);
  static double get borderWidth => 1.w;
}

// Text Styles - Responsive text styles using ScreenUtil
class AppTextStyles {
  // Headings
  static TextStyle get h1 => TextStyle(
    fontSize: AppTexts.xxxl,
    fontWeight: AppTexts.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get h2 => TextStyle(
    fontSize: AppTexts.xxl,
    fontWeight: AppTexts.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get h3 => TextStyle(
    fontSize: AppTexts.xl,
    fontWeight: AppTexts.semiBold,
    color: AppColors.textPrimary,
  );

  static TextStyle get h4 => TextStyle(
    fontSize: AppTexts.lg,
    fontWeight: AppTexts.semiBold,
    color: AppColors.textPrimary,
  );

  // Body Text
  static TextStyle get bodyLarge => TextStyle(
    fontSize: AppTexts.md,
    fontWeight: AppTexts.regular,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontSize: AppTexts.sm,
    fontWeight: AppTexts.regular,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => TextStyle(
    fontSize: AppTexts.xs,
    fontWeight: AppTexts.regular,
    color: AppColors.textSecondary,
  );

  // Button Text
  static TextStyle get buttonLarge => TextStyle(
    fontSize: AppTexts.md,
    fontWeight: AppTexts.semiBold,
    color: AppColors.textOnPrimary,
  );

  static TextStyle get buttonMedium => TextStyle(
    fontSize: AppTexts.sm,
    fontWeight: AppTexts.medium,
    color: AppColors.textOnPrimary,
  );

  // Caption & Labels
  static TextStyle get caption => TextStyle(
    fontSize: AppTexts.xs,
    fontWeight: AppTexts.regular,
    color: AppColors.textTertiary,
  );

  static TextStyle get label => TextStyle(
    fontSize: AppTexts.sm,
    fontWeight: AppTexts.medium,
    color: AppColors.textSecondary,
  );

  // Special Text Styles
  static TextStyle get primaryButton => TextStyle(
    fontSize: AppTexts.md,
    fontWeight: AppTexts.semiBold,
    color: AppColors.white,
  );

  static TextStyle get secondaryButton => TextStyle(
    fontSize: AppTexts.md,
    fontWeight: AppTexts.medium,
    color: AppColors.primary,
  );

  static TextStyle get link => TextStyle(
    fontSize: AppTexts.sm,
    fontWeight: AppTexts.medium,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );
}
