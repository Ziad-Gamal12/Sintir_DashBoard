import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CustomFilterTicketsStatusItem extends StatelessWidget {
  const CustomFilterTicketsStatusItem({
    super.key,
    required this.label,
    required this.isSelected,
  });
  final String label;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primary : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: AppTextStyles(context).regular11.copyWith(
          color: isSelected
              ? Colors.white
              : theme.textTheme.bodySmall?.color?.withOpacity(0.8),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
