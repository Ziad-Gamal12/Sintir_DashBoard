import 'package:flutter/material.dart';

class SubscriberGenderBadge extends StatelessWidget {
  final bool isMale;
  final String gender;

  const SubscriberGenderBadge({
    super.key,
    required this.isMale,
    required this.gender,
  });

  @override
  Widget build(BuildContext context) {
    final color = isMale ? Colors.blue.shade400 : Colors.pink.shade300;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        gender,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
