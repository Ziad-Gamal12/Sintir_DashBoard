import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TicketSenderInfo extends StatelessWidget {
  final String senderName;
  final DateTime date;

  const TicketSenderInfo({
    super.key,
    required this.senderName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.person_rounded,
            size: 18,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "المُرسل",
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
              ),
              Text(
                senderName,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Text(
          DateFormat('yyyy/MM/dd').format(date),
          style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}
