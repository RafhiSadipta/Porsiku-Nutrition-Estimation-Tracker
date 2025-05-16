import 'package:flutter/material.dart';

class AppIcons {
  static const double xs = 16;
  static const double sm = 20;
  static const double md = 24;
  static const double lg = 30;
  static const double xl = 48;
}

class AppTexts {
  static const double xs = 12;
  static const double sm = 14;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
}

class AppBorderRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double infinity = 100;
}

class AppColors {
  // static const Color primary = Color(0xFF222222);
  // static const Color secondary = Color(0xFF4F4F4F);
  // static const Color accent = Color(0xFFFFC107);
  static const Color background = Color(0xFFF8F8F8);
  static const Color black = Color(0xFF0B1215);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFFABADB0);
  static const Color lightGrey = Color(0xFFD9D9D9);
  static const Color darkGrey = Color(0xFF707173);
  static const Color red = Color(0xFFFF6D61);
  static const Color green = Color(0xFF91D15F);
  static const Color blue = Color(0xFF41ADFB);
  static const Color yellow = Color(0xFFECBC00);
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
      color: Color.fromRGBO(0, 0, 0, 0.15),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  static const List<BoxShadow> smButton = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.15),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];
}
