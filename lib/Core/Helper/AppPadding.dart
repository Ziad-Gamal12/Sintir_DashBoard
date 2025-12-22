import 'package:flutter/material.dart';

class AppPadding {
  static double horizontal(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    if (width > 1200) return 80.0;
    if (width > 600) return 32.0;
    return 16.0;
  }

  static double vertical(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    return width > 600 ? 40.0 : 20.0;
  }
}
