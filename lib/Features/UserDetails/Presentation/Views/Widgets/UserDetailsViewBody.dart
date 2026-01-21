import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/Transactions/TransactionEntity.dart';
import 'package:sintir_dashboard/Core/Helper/AppPadding.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserInfoCard/CustomUserInfoCard.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/SectionHeader.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserDetailsDesktopLayout.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserDetailsMobileLayout.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserTransactionsSliverGrid.dart';

class UserDetailsViewBody extends StatelessWidget {
  const UserDetailsViewBody({super.key, required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context) {
    final bool isWideLayout = MediaQuery.sizeOf(context).width > 1100;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.horizontal(context),
        vertical: AppPadding.vertical(context),
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: CustomUserInfoCard()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // Responsive Container Widget
          SliverToBoxAdapter(
            child: isWideLayout
                ? const UserDetailsDesktopLayout()
                : const UserDetailsMobileLayout(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          SliverToBoxAdapter(child: SectionHeader(title: "المعاملات المالية")),
          SliverToBoxAdapter(child: const SizedBox(height: 16)),

          UserTransactionsSliverGrid(
            transactions: TransactionEntity.getTestTransactions(),
          ),
        ],
      ),
    );
  }
}
