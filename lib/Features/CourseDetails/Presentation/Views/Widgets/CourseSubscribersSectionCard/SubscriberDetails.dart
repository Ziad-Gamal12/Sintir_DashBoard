import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/SubscriberEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class SubscriberDetails extends StatelessWidget {
  final SubscriberEntity subscriber;
  const SubscriberDetails({super.key, required this.subscriber});

  @override
  Widget build(BuildContext context) {
    final styles = AppTextStyles(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          subscriber.name,
          style: styles.bold16,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          subscriber.educationLevel,
          style: styles.medium12.copyWith(color: const Color(0xFF2196F3)),
        ),
      ],
    );
  }
}
