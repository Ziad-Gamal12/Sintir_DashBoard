import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomCourseSectionsCardHeader extends StatelessWidget {
  const CustomCourseSectionsCardHeader({
    super.key,
    required this.title,
    this.showMore,
    this.action,
  });

  final String title;
  final VoidCallback? showMore;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyles = AppTextStyles(context);

    return Row(
      children: [
        // 1. Accent Bar
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: KMainColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),

        // 2. Title (Wrapped in Expanded to prevent overflow)
        Expanded(
          child: Text(
            title,
            maxLines: 1, // Keep it on one line
            overflow: TextOverflow.ellipsis, // Add "..." if text is too long
            style: textStyles.semiBold16.copyWith(
              // Slightly smaller for better fit
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showMore != null)
              TextButton(
                onPressed: showMore,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "المزيد",
                  style: textStyles.regular13.copyWith(color: KMainColor),
                ),
              ),
            if (action != null) ...[const SizedBox(width: 4), action!],
          ],
        ),
      ],
    );
  }
}
