import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserActivityCardItem.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomUserActivityCardsRow extends StatelessWidget {
  const CustomUserActivityCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bool isSmallScreen = width < 600;

    // If screen is small, we allow horizontal scrolling.
    // If large, we use Expanded to fill the dashboard width.
    return isSmallScreen ? _buildScrollableRow() : _buildExpandedRow();
  }

  // Desktop/Tablet: Cards expand to fill width equally
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

  // Mobile: Cards have a fixed width and are scrollable to prevent overflow
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
  Widget build(BuildContext context) => CustomUserActivityCardItem(
    value: "1250",
    title: "مجموع المصروفات",
    color: KMainColor,
    icon: FontAwesomeIcons.wallet,
    unit: "جنية",
  );
}

class _GraduationCard extends StatelessWidget {
  const _GraduationCard();
  @override
  Widget build(BuildContext context) => const CustomUserActivityCardItem(
    value: "10",
    title: "مجموع الكورسات",
    color: KSecondaryColor,
    icon: FontAwesomeIcons.graduationCap,
  );
}

class _TicketCard extends StatelessWidget {
  const _TicketCard();
  @override
  Widget build(BuildContext context) => const CustomUserActivityCardItem(
    value: "4",
    title: "مجموع التذاكر",
    color: Colors.amber,
    icon: FontAwesomeIcons.ticket,
  );
}
