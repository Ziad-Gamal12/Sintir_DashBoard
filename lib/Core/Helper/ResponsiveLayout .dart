import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    required this.mobile,
    required this.tablet,
    required this.desktop,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;

        if (width == double.infinity) {
          width = MediaQuery.sizeOf(context).width;
        }
        if (width < 600) {
          return mobile;
        } else if (width < 1100) {
          return tablet;
        } else {
          return desktop;
        }
      },
    );
  }
}
