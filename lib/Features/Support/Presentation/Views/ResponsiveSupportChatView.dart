import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Helper/ResponsiveLayout%20.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportTicketEntity.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/SupportChatDesktopView.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/SupportChatMobileView.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/SupportChatTabletView.dart';

class ResponsiveSupportChatView extends StatelessWidget {
  const ResponsiveSupportChatView({
    super.key,
    required this.supportTicketEntity,
  });
  static const routeName = '/ResponsiveSupportChatView';
  final SupportTicketEntity supportTicketEntity;

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: SupportChatMobileView(supportTicket: supportTicketEntity),
      tablet: SupportChatTabletView(supportTicket: supportTicketEntity),
      desktop: SupportChatDesktopView(supportTicket: supportTicketEntity),
    );
  }
}
