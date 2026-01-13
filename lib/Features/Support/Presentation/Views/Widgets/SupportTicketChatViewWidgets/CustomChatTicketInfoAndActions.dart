import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportTicketEntity.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Repos/SupportTicketsRepo.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Managers/support_tickets_cubit/support_tickets_cubit.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/CustomChatTicketInfoAndActionsHandler.dart';

class CustomChatTicketInfoAndActions extends StatelessWidget {
  const CustomChatTicketInfoAndActions({super.key, required this.ticket});

  final SupportTicketEntity ticket;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SupportTicketsCubit(supportTicketsRepo: getIt<SupportTicketsRepo>()),
      child: CustomChatTicketInfoAndActionsHandler(ticket: ticket),
    );
  }
}
