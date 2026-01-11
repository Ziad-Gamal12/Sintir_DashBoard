import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/FilterTicketsQueryEntity.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Repos/SupportTicketsRepo.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Managers/support_tickets_cubit/support_tickets_cubit.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/TicketsManagementViewBodyHandler.dart';

class TicketsManagementViewBody extends StatelessWidget {
  const TicketsManagementViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SupportTicketsCubit(supportTicketsRepo: getIt<SupportTicketsRepo>())
            ..getSupportTickets(FilterTicketsQueryEntity(), isPaginate: false),
      child: TicketsManagementViewBodyHandler(),
    );
  }
}
