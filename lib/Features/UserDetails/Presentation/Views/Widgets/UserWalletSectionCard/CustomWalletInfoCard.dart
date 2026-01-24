// ignore_for_file: must_be_immutable, file_names

import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CustomWalletInfoCard extends StatelessWidget {
  const CustomWalletInfoCard({
    super.key,
    required this.label,
    required this.value,
    required this.currency,
    this.icon,
    this.color = Colors.blue,
  });

  final String label, value, currency;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles(context);

    return Container(
      constraints: const BoxConstraints(minWidth: 260, maxWidth: 400),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: color.withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: textStyles.semiBold14.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (icon != null) Icon(icon, color: color, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: textStyles.bold24.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currency,
                        style: textStyles.semiBold14.copyWith(color: color),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
