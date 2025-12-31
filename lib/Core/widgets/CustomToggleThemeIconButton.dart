import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sintir_dashboard/Core/Themes/theme_cubit.dart';

class CustomToggleThemeIconButton extends StatelessWidget {
  const CustomToggleThemeIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      onPressed: () => context.read<ThemeCubit>().toggleTheme(),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return RotationTransition(
            turns: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: Icon(
          isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey<bool>(isDarkMode),
          size: 24,
          color: isDarkMode ? Colors.amber : Colors.blueGrey[800],
        ),
      ),
    );
  }
}
