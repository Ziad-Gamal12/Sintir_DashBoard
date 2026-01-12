import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportTicketEntity.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Repos/SupportChatRepo.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Managers/support_chat_cubit/support_chat_cubit.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/CustomSupportChatSendMessageSection.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/SupportChatMessagesListView.dart';

class SupportTicketChatViewBody extends StatelessWidget {
  const SupportTicketChatViewBody({
    super.key,
    required this.supportTicketEntity,
  });
  final SupportTicketEntity supportTicketEntity;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (context) =>
          SupportChatCubit(supportChatRepo: getIt.get<SupportChatRepo>()),
      child: Stack(
        children: [
          Positioned.fill(
            child: SupportChatMessagesListView(
              ticketID: supportTicketEntity.id,
            ),
          ),
          Positioned(
            left: width * 0.15,
            right: width * 0.15,
            bottom: 20,
            child: CustomSupportChatSendMessageSection(
              ticketId: supportTicketEntity.id,
            ),
          ),
        ],
      ),
    );
  }
}
