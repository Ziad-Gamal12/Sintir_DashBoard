import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/TeacherWalletEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserWalletSectionCard/CustomWalletInfoCard.dart';
import 'package:sintir_dashboard/constant.dart';

class WalletInfoWrapCards extends StatelessWidget {
  const WalletInfoWrapCards({super.key, required this.wallet});
  final WalletEntity wallet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildResponsiveItem(
              constraints,
              CustomWalletInfoCard(
                label: "الرصيد المتاح",
                currency: wallet.currency,
                color: KMainColor,
                icon: Icons.account_balance_wallet_outlined,
                value: wallet.balance.toString(),
              ),
            ),
            _buildResponsiveItem(
              constraints,
              CustomWalletInfoCard(
                label: "إجمالي الأرباح",
                currency: wallet.currency,
                color: Colors.green,
                icon: Icons.trending_up_rounded,
                value: wallet.totalEarned.toString(),
              ),
            ),
            _buildResponsiveItem(
              constraints,
              CustomWalletInfoCard(
                label: "المبالغ المعلقة",
                currency: wallet.currency,
                color: Colors.orange,
                icon: Icons.hourglass_empty_rounded,
                value: wallet.payoutPending.toString(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResponsiveItem(BoxConstraints constraints, Widget child) {
    bool isMobile = constraints.maxWidth < 600;
    return SizedBox(width: isMobile ? constraints.maxWidth : 300, child: child);
  }
}
