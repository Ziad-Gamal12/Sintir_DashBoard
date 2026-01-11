import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportChatMessageEntity.dart';

class SupportChatContent extends StatelessWidget {
  final SupportChatMessageEntity message;
  final bool isMe;
  final Color textColor;
  final Color timeColor;

  const SupportChatContent({
    super.key,
    required this.message,
    required this.isMe,
    required this.textColor,
    required this.timeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.image != null)
          AspectRatio(
            aspectRatio: 16 / 10,
            child: Hero(
              tag: message.id,
              child: CustomCachedNetworkImage(
                imageUrl: message.image!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                message.message,
                style: TextStyle(color: textColor, fontSize: 15, height: 1.3),
              ),
              _buildTimestamp(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimestamp() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormat('hh:mm a').format(message.createdAt),
          style: TextStyle(color: timeColor, fontSize: 10),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          Icon(Icons.done_all, size: 14, color: timeColor),
        ],
      ],
    );
  }
}
