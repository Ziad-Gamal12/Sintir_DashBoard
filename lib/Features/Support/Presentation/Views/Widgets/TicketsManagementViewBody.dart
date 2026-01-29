import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Helper/GetUserData.dart';
import 'package:sintir_dashboard/Core/Permissions/Permissions%20Mapping.dart';
import 'package:sintir_dashboard/Core/Services/get_it_Service.dart';
import 'package:sintir_dashboard/Core/widgets/AccessDeniedWidget.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Repos/SupportAnalyticsRepo.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Repos/SupportTicketsRepo.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Managers/TicketAnalyticsCubit/ticket_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Managers/support_tickets_cubit/support_tickets_cubit.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/TicketsManagementViewBodyHandler.dart';

class TicketsManagementViewBody extends StatelessWidget {
  const TicketsManagementViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final user = getUserData();

    final bool canViewTickets = PermissionsManager.can(
      Permission.viewTickets,
      role: user.role,
      status: user.status,
    );

    if (!canViewTickets) {
      return const AccessDeniedWidgetAr(
        featureNameAr: "إدارة التذاكر والدعم الفني",
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SupportTicketsCubit(
            supportTicketsRepo: getIt<SupportTicketsRepo>(),
          ),
        ),
        BlocProvider(
          create: (context) => TicketAnalyticsCubit(
            supportRepo: getIt<SupportAnalyticsRepo>(),
          ),
        ),
      ],
      child: const TicketsManagementViewBodyHandler(),
    );
  }
}