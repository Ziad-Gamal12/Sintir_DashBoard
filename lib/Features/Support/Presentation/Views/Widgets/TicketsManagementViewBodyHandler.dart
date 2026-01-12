import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Core/Helper/AppPadding.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/FilterTicketsQueryEntity.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportTicketEntity.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Managers/TicketAnalyticsCubit/ticket_analytics_cubit.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Managers/support_tickets_cubit/support_tickets_cubit.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/CustomTicketsSummaryCardGrid.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/TicketsFilterSection.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/TicketsManagmentHeader.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/TicketsSliverList.dart';

class TicketsManagementViewBodyHandler extends StatefulWidget {
  const TicketsManagementViewBodyHandler({super.key});

  @override
  State<TicketsManagementViewBodyHandler> createState() =>
      _TicketsManagementViewBodyHandlerState();
}

class _TicketsManagementViewBodyHandlerState
    extends State<TicketsManagementViewBodyHandler> {
  late ScrollController _scrollController;
  FilterTicketsQueryEntity? filterTicketsQueryEntity =
      FilterTicketsQueryEntity();
  bool hasMore = true;
  List<SupportTicketEntity> supportTickets = [];
  final FilterTicketsQueryEntity _filterEntity = FilterTicketsQueryEntity();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<SupportTicketsCubit>().getSupportTickets(
        _filterEntity,
        isPaginate: false,
      );
      context.read<TicketAnalyticsCubit>().fetchAllStats();
    });
  }

  void _onScroll() {
    final cubit = context.read<SupportTicketsCubit>();
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        hasMore &&
        cubit.state is! GetSupportTicketsLoading) {
      cubit.getSupportTickets(_filterEntity, isPaginate: true);
    }
  }

  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (val.trim() != _filterEntity.id) {
        _filterEntity.id = val.trim();
        context.read<SupportTicketsCubit>().getSupportTickets(
          _filterEntity,
          isPaginate: false,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SupportTicketsCubit, SupportTicketsState>(
      listener: (context, state) {
        if (state is GetSupportTicketsSuccess) {
          if (state.response.isPaginate) {
            supportTickets.addAll(state.response.supportTickets);
          } else {
            supportTickets = state.response.supportTickets;
          }
          hasMore = state.response.hasMore;
          setState(() {});
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppPadding.horizontal(context),
          vertical: AppPadding.vertical(context),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: TicketsManagmentHeader()),
            SliverToBoxAdapter(child: SizedBox(height: 48)),
            CustomTicketsSummaryCardGrid(),
            SliverToBoxAdapter(child: Divider(height: 48)),
            SliverToBoxAdapter(
              child: TicketsFilterSection(
                onSearchChanged: _onSearchChanged,
                onStatusChanged: (val) {
                  if (val != _filterEntity.status) {
                    _filterEntity.status = val;
                    context.read<SupportTicketsCubit>().getSupportTickets(
                      _filterEntity,
                      isPaginate: false,
                    );
                  }
                },
              ),
            ),

            SliverToBoxAdapter(child: Divider(height: 48)),
            TicketsSliverList(supportTickets: supportTickets),
          ],
        ),
      ),
    );
  }
}
