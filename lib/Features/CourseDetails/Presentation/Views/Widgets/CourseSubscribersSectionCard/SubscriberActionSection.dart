import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Presentation/Views/Widgets/CourseSubscribersSectionCard/DeleteSubscriberActionButton.dart';

class SubscriberActionSection extends StatelessWidget {
  final DateTime joinedDate;
  final VoidCallback onNaviagte;
  final VoidCallback onDelete;
  final String subscriberId;

  const SubscriberActionSection({
    super.key,
    required this.joinedDate,
    required this.onNaviagte,
    required this.onDelete,
    required this.subscriberId,
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
        DeleteSubscriberActionButton(
          onPressed: onDelete,
          subscriberId: subscriberId,
        ),
      ],
    );
  }
}
