import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Helper/AppPadding.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Presentation/Views/Widgets/CustomTicketsSummaryCardGrid.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Presentation/Views/Widgets/TicketsFilterSection.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Presentation/Views/Widgets/TicketsManagmentHeader.dart';
import 'package:sintir_dashboard/Features/TicketsManagement/Presentation/Views/Widgets/TicketsSliverList.dart';

class TicketsManagementViewBody extends StatelessWidget {
  const TicketsManagementViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.horizontal(context),
        vertical: AppPadding.vertical(context),
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: TicketsManagmentHeader()),
          SliverToBoxAdapter(child: SizedBox(height: 48)),
          CustomTicketsSummaryCardGrid(),
          SliverToBoxAdapter(child: Divider(height: 48)),
          SliverToBoxAdapter(
            child: TicketsFilterSection(onStatusChanged: (val) {}),
          ),
          SliverToBoxAdapter(child: Divider(height: 48)),
          TicketsSliverList(),
        ],
      ),
    );
  }
}
