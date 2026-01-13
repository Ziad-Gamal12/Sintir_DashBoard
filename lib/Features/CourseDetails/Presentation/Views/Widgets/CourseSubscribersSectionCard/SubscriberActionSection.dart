import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class SubscriberActionSection extends StatelessWidget {
  final DateTime joinedDate;
  final VoidCallback onNaviagte;
  final VoidCallback onDelete;

  const SubscriberActionSection({
    super.key,
    required this.joinedDate,
    required this.onNaviagte,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final styles = AppTextStyles(context);
    String date = DateFormat('yMMMd').format(joinedDate);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "تاريخ الاشتراك",
              style: styles.semiBold10.copyWith(color: Colors.grey),
            ),
            Text(date, style: styles.semiBold12),
          ],
        ),
        const SizedBox(width: 16),
        _ActionButton(
          icon: Icons.delete_outline_rounded,
          color: Colors.redAccent.withOpacity(0.1),
          iconColor: Colors.redAccent,
          onPressed: onDelete,
          tooltip: "حذف",
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onPressed;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.all(8),
      style: IconButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 18, color: iconColor),
    );
  }
}
