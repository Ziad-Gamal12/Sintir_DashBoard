import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CustomInfoRow extends StatelessWidget {
  CustomInfoRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.child,
  });
  final String label, value;
  Widget? child;
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
          SizedBox(width: 12),
          Expanded(
            child:
                child ??
                Text(
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
