import 'package:flutter/material.dart';

class Responsive {
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static bool isSmall(BuildContext context) => width(context) < 360;
  static bool isMedium(BuildContext context) =>
      width(context) >= 360 && width(context) < 600;
  static bool isTablet(BuildContext context) =>
      width(context) >= 600 && width(context) < 900;
  static bool isDesktop(BuildContext context) => width(context) >= 900;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  // Helper for font sizing
  static double fontSize(BuildContext context, double size) {
    if (isSmall(context)) {
      return size * 0.85;
    } else if (isTablet(context)) {
      return size * 1.2;
    }
    return size;
  }
}
