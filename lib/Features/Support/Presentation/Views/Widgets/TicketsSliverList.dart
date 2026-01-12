import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/widgets/CustomEmptyWidget.dart';
import 'package:sintir_dashboard/Core/widgets/CustomErrorWidget.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportTicketEntity.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Managers/support_tickets_cubit/support_tickets_cubit.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/SupportChatMobileView.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/TicketItem.dart';
import 'package:sintir_dashboard/constant.dart';

class TicketsSliverList extends StatelessWidget {
  const TicketsSliverList({super.key, required this.supportTickets});
  final List<SupportTicketEntity> supportTickets;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupportTicketsCubit, SupportTicketsState>(
      buildWhen: (previous, current) =>
          current is GetSupportTicketsSuccess ||
          current is GetSupportTicketsFailure ||
          current is GetSupportTicketsLoading,
      builder: (context, state) {
        if (state is GetSupportTicketsFailure) {
          return SliverToBoxAdapter(
            child: Center(
              child: CustomErrorWidget(errormessage: state.errMessage),
            ),
          );
        } else if (state is GetSupportTicketsLoading &&
            state.isPaginate == false) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator(color: KMainColor)),
          );
        } else if (supportTickets.isEmpty &&
            state is GetSupportTicketsSuccess) {
          return SliverToBoxAdapter(
            child: Center(child: CustomEmptyWidget(text: "لا يوجد تذاكر")),
          );
        }
        return SliverList.builder(
          itemCount: state is GetSupportTicketsLoading && state.isPaginate
              ? supportTickets.length + 1
              : supportTickets.length,
          itemBuilder: (context, index) {
            if (index == supportTickets.length) {
              return const Center(
                child: CircularProgressIndicator(color: KMainColor),
              );
            }
            return TicketItem(
              ticket: supportTickets[index],
              onTap: () {
                GoRouter.of(context).push(
                  ResponsiveSupportChatView.routeName,
                  extra: supportTickets[index],
                );
              },
            );
          },
        );
      },
    );
  }
}
