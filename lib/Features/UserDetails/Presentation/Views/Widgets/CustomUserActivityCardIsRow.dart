import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Managers/user_details_cubit/user_details_cubit.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserActivityCardItem.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomUserActivityCardsRow extends StatelessWidget {
  const CustomUserActivityCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool isSmallScreen = width < 600;
    return isSmallScreen ? _buildScrollableRow() : _buildExpandedRow();
  }

  Widget _buildExpandedRow() {
    return const Row(
      children: [
        Expanded(child: _WalletCard()),
        SizedBox(width: 16),
        Expanded(child: _GraduationCard()),
        SizedBox(width: 16),
        Expanded(child: _TicketCard()),
      ],
    );
  }

  Widget _buildScrollableRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: const Row(
        children: [
          SizedBox(width: 160, child: _WalletCard()),
          SizedBox(width: 16),
          SizedBox(width: 160, child: _GraduationCard()),
          SizedBox(width: 16),
          SizedBox(width: 160, child: _TicketCard()),
        ],
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard();
  @override
  Widget build(BuildContext context) {
    double transactionsAmount = context
        .watch<UserDetailsCubit>()
        .userTransactionsAmount;
    return CustomUserActivityCardItem(
      value: transactionsAmount.toString(),
      title: "مجموع المصروفات",
      color: KMainColor,
      icon: FontAwesomeIcons.wallet,
      unit: "جنية",
    );
  }
}

class _GraduationCard extends StatelessWidget {
  const _GraduationCard();
  @override
  Widget build(BuildContext context) {
    int coursesCount = context.watch<UserDetailsCubit>().userSubscriptionsCount;
    return CustomUserActivityCardItem(
      value: coursesCount.toString(),
      title: "مجموع الكورسات",
      color: KSecondaryColor,
      icon: FontAwesomeIcons.graduationCap,
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard();
  @override
  Widget build(BuildContext context) {
    int ticketsCount = context
        .watch<UserDetailsCubit>()
        .userSupportTicketsCount;
    return CustomUserActivityCardItem(
      value: ticketsCount.toString(),
      title: "مجموع التذاكر",
      color: Colors.amber,
      icon: FontAwesomeIcons.ticket,
    );
  }
}
