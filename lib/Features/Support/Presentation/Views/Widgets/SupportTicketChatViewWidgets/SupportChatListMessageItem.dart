import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportChatMessageEntity.dart';

import 'SupportChatContent.dart';
import 'SupportChatHeader.dart';

class SupportChatListMessageItem extends StatelessWidget {
  final SupportChatMessageEntity messageEntity;
  final bool isMe;
  final VoidCallback? onLongPress;

  const SupportChatListMessageItem({
    super.key,
    required this.messageEntity,
    required this.isMe,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

    // TL TIP: Define a static max width for Desktop so bubbles don't look like bars
    final double maxBubbleWidth = screenWidth > 900 ? 450 : screenWidth * 0.75;

    final Color bubbleColor = isMe
        ? theme.primaryColor
        : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5);

    final Color textColor = isMe
        ? Colors.white
        : theme.colorScheme.onSurfaceVariant;
    final Color timeColor = isMe ? Colors.white70 : theme.colorScheme.outline;

    return GestureDetector(
      onLongPress: isMe ? onLongPress : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Align(
          alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisSize:
                MainAxisSize.min, // 2. Keep column tight to its content
            children: [
              if (!isMe) SupportChatHeader(sender: messageEntity.sender),
              const SizedBox(height: 4),
              Material(
                borderRadius: _getBorderRadius(),
                clipBehavior: Clip.antiAlias,
                color: bubbleColor,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth:
                        maxBubbleWidth, // 3. Use the responsive constraint
                  ),
                  child: SupportChatContent(
                    message: messageEntity,
                    isMe: isMe,
                    textColor: textColor,
                    timeColor: timeColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BorderRadius _getBorderRadius() => BorderRadius.only(
    topLeft: const Radius.circular(16),
    topRight: const Radius.circular(16),
    bottomLeft: Radius.circular(isMe ? 16 : 4),
    bottomRight: Radius.circular(isMe ? 4 : 16),
  );
}
