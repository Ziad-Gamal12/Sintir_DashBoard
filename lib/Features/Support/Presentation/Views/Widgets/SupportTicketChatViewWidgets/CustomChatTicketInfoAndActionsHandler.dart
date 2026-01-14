import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Helper/ShowSnackBar.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportTicketEntity.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Managers/support_tickets_cubit/support_tickets_cubit.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/CustomChatTicketActionCard.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/CustomChatTicketDetailsCard.dart';

class CustomChatTicketInfoAndActionsHandler extends StatelessWidget {
  const CustomChatTicketInfoAndActionsHandler({
    super.key,
    required this.ticket,
  });

  final SupportTicketEntity ticket;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupportTicketsCubit, SupportTicketsState>(
      listener: (context, state) {
        if (state is UpdateSupportTicketStatusSuccess) {
          CustomSnackBar.show(
            context,
            message: "تم تحديث حالة التذكرة بنجاح",
            type: SnackType.success,
          );
        } else if (state is UpdateSupportTicketStatusFailure) {
          CustomSnackBar.show(
            context,
            message: state.errMessage,
            type: SnackType.error,
          );
        } else if (state is DeleteSupportTicketSuccess) {
          CustomSnackBar.show(
            context,
            message: "تم حذف التذكرة بنجاح",
            type: SnackType.success,
          );
          Navigator.pop(context);
        } else if (state is DeleteSupportTicketFailure) {
          CustomSnackBar.show(
            context,
            message: state.errMessage,
            type: SnackType.error,
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomChatTicketDetailsCard(
                    supportTicketEntity: ticket,
                    isDesktop: true,
                  ),
                  const SizedBox(height: 16),
                  BlocSelector<SupportTicketsCubit, SupportTicketsState, bool>(
                    selector: (state) {
                      return state is DeleteSupportTicketLoading;
                    },
                    builder: (context, isLoading) {
                      return CustomChatTicketActionCard(
                        currentStatus: ticket.status,
                        onStatusChanged: (val) => context
                            .read<SupportTicketsCubit>()
                            .changeSupportTicketStatus(
                              ticketId: ticket.id,
                              status: val,
                            ),
                        isDeletingLoading: isLoading,
                        onDeleteTicket: () => context
                            .read<SupportTicketsCubit>()
                            .deleteSupportTicket(ticketId: ticket.id),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
