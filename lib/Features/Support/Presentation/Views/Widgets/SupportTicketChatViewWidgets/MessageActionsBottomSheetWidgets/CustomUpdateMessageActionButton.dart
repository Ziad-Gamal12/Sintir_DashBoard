import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Helper/ShowBottomSheet.dart';
import 'package:sintir_dashboard/Core/widgets/CustomButton.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportChatMessageEntity.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/UpdateMessageBottomSheetWidgets/UpdateMessageBottomSheet.dart';

class CustomUpdateMessageActionButton extends StatelessWidget {
  const CustomUpdateMessageActionButton({
    super.key,
    required this.ticketId,
    required this.messageEntity,
  });
  final String ticketId;
  final SupportChatMessageEntity messageEntity;
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Custombutton(
        text: "تعديل",
        color: Colors.transparent,
        side: BorderSide(width: 1, color: theme.colorScheme.primary),
        textColor: theme.colorScheme.primary,
        onPressed: () {
          showCustomModalBottomSheet(
            child: UpdateMessageBottomSheet(
              ticketId: ticketId,
              messageEntity: messageEntity,
            ),
            context: context,
          );
        },
      ),
    );
  }
}
