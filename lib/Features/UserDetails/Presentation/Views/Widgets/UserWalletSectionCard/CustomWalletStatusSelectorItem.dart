import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Features/UserDetails/Domain/Entities/WalletStatusSelectorEntity.dart';

class CustomWalletStatusSelectorItem extends StatelessWidget {
  const CustomWalletStatusSelectorItem({
    super.key,
    required this.item,
    this.isSelected = false,
    this.onTap,
  });

  final WalletStatusSelectorEntity item;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final styles = AppTextStyles(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final Color backgroundColor = isSelected
        ? (isDarkMode
              ? item.color.withOpacity(0.15)
              : item.color.withOpacity(0.12))
        : (isDarkMode ? const Color(0xFF1E1E26) : Colors.white);

    // Border: Vibrant when selected, subtle when not
    final Color borderColor = isSelected
        ? item.color
        : (isDarkMode
              ? Colors.white10
              : const Color(0xFFE0E0E0).withOpacity(0.5));
    final Color textColor = isSelected
        ? (isDarkMode ? item.color : item.color.withOpacity(0.9))
        : (isDarkMode ? const Color(0xFF9EA3AE) : const Color(0xFF424752));
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        constraints: const BoxConstraints(
          minHeight: 60,
          minWidth: 140,
          maxWidth: 220,
        ),
        duration: const Duration(milliseconds: 250),
        curve: Curves.decelerate,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 1.0, // Thicker border on selection
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: item.color.withOpacity(isDarkMode ? 0.2 : 0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with a subtle circular backing
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? item.color.withOpacity(0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: isSelected ? item.color : textColor.withOpacity(0.7),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                item.statusLabel,
                overflow: TextOverflow.ellipsis,
                style: styles.semiBold14.copyWith(
                  color: textColor,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
