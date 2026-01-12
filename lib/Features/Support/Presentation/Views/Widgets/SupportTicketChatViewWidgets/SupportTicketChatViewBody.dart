import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportTicketEntity.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Repos/SupportChatRepo.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Managers/support_chat_cubit/support_chat_cubit.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/DesktopLayout.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/MobileLayout.dart';

class SupportTicketChatViewBody extends StatelessWidget {
  const SupportTicketChatViewBody({
    super.key,
    required this.supportTicketEntity,
  });

  final SupportTicketEntity supportTicketEntity;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SupportChatCubit(supportChatRepo: getIt.get<SupportChatRepo>()),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isDesktop = constraints.maxWidth > 900;

          return isDesktop
              ? DesktopLayout(ticket: supportTicketEntity)
              : MobileLayout(ticket: supportTicketEntity);
        },
      ),
    );
  }
}
