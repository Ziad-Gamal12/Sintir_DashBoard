import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Core/Entities/CustomDrawerEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomDrawerItem extends StatelessWidget {
  const CustomDrawerItem({
    // Removed mutable 'color' and 'ignore' tag
    super.key,
    required this.drawerItem,
    required this.isSelected,
    this.overrideColor, // Renamed for clarity
  });

  final CustomDrawerEntity drawerItem;
  final bool isSelected;
  final Color? overrideColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color effectiveActiveColor = isDark ? Colors.white : Colors.white;
    final Color effectiveInactiveColor = isDark
        ? const Color(0xFF8E99A8)
        : Colors.black54;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? (overrideColor?.withOpacity(0.15) ??
                  KMainColor.withOpacity(isDark ? 0.15 : 0.65))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected && isDark
            ? Border.all(
                color: (overrideColor ?? KMainColor).withOpacity(0.2),
                width: 1,
              )
            : Border.all(color: Colors.transparent, width: 1),
      ),
      child: Row(
        children: [
          FaIcon(
            drawerItem.icon,
            color: _getItemColor(effectiveActiveColor, effectiveInactiveColor),
            size: 18,
          ),
          const SizedBox(width: 12),
          Text(
            drawerItem.title,
            style: AppTextStyles(context).semiBold14.copyWith(
              color: _getItemColor(
                effectiveActiveColor,
                effectiveInactiveColor,
              ),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Color _getItemColor(Color active, Color inactive) {
    if (overrideColor != null) return overrideColor!;
    return isSelected ? active : inactive;
  }
}
