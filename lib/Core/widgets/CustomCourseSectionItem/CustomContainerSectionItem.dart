import 'package:flutter/material.dart';

class Customcontainersectionitem extends StatelessWidget {
  const Customcontainersectionitem({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      alignment: AlignmentDirectional.center,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
