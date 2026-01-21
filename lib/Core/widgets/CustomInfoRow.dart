import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CustomInfoRow extends StatelessWidget {
  const CustomInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8E99AF), size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8E99AF), fontSize: 15),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,

              style: textStyles.medium12,
            ),
          ),
        ],
      ),
    );
  }
}
