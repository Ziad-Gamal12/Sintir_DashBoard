import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportTicketEntity.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/CustomChatTicketInfoAndActions.dart';

class ChatMobileLayoutHelper {
  static void showActionSheet(
    BuildContext context,
    SupportTicketEntity ticket,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: FadeTransition(
            opacity: anim1,
            child: ScaleTransition(
              scale: anim1,
              child: CustomChatTicketInfoAndActions(ticket: ticket),
            ),
          ),
        );
      },
    );
  }
}
