import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    final Color containerColor = theme.cardColor;

    final List<BoxShadow> boxShadows = isDarkMode
        ? [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(2, 5),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 50,
              spreadRadius: 1,
              offset: const Offset(5, 15),
            ),
          ];

    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Use theme-aware color instead of hardcoded Colors.white
          color: containerColor,
          // Use theme-aware shadows
          boxShadow: boxShadows,
          borderRadius: BorderRadius.circular(20),
        ),
        child: child);
  }
}
