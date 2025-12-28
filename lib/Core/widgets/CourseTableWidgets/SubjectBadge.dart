import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/constant.dart';

class SubjectBadge extends StatelessWidget {
  const SubjectBadge({super.key, required this.subject});
  final String subject;
  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles(context);
    return UnconstrainedBox(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: KMainColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          subject,
          style: textStyles.semiBold12.copyWith(color: KMainColor),
        ),
      ),
    );
  }
}
