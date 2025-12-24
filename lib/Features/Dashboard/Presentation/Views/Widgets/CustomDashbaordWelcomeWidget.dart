import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Helper/GetUserData.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';

class CustomDashboardWelcomeWidget extends StatelessWidget {
  const CustomDashboardWelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final UserEntity user = getUserData();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        // Text Section
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "أهلاً بك مجدداً، ${user.fullName.split(' ')[0]} 👋",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "إليك ما يحدث في منصة سنتير اليوم. نتمنى لك يوماً منتجاً!",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
