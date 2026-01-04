import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/imageAssets.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CustomEmptyWidget extends StatelessWidget {
  final String? text;
  final String? subText;

  const CustomEmptyWidget({super.key, this.text, this.subText});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyles = AppTextStyles(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(isDark ? 0.05 : 0.1),
                    blurRadius: 50,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Opacity(
                opacity: 0.85,
                child: Image.asset(
                  Assets.assetsIconsEmptyBox,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              text ?? "لا توجد بيانات حالياً",
              style: textStyles.semiBold16.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
