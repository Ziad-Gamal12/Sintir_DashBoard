import 'package:flutter/material.dart';
import 'package:sintir_dashboard/constant.dart';

class PageViewItemHeaderFooter extends StatelessWidget {
  const PageViewItemHeaderFooter({
    super.key,
    required this.isSelected,
    required this.footerBgColor,
    required this.footerCount,
  });

  final bool isSelected;
  final Color? footerBgColor;
  final int footerCount;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? KMainColor.withOpacity(0.1)
            : (footerBgColor?.withOpacity(0.1) ?? Colors.grey),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? KMainColor.withOpacity(0.2)
                : (footerBgColor?.withOpacity(0.2) ??
                      Colors.grey.withOpacity(0.2)),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        footerCount.toString(),
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: isSelected ? KMainColor : (footerBgColor ?? Colors.grey),
        ),
      ),
    );
  }
}
