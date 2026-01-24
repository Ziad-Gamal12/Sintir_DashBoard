import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Core/widgets/CustomInfoRow.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/TeacherWalletEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserWalletSectionCard/UserWalletSectionCardHeader.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserWalletSectionCard/WalletInfoWrapCards.dart';

class UserWalletSectionCard extends StatelessWidget {
  const UserWalletSectionCard({super.key, required this.wallet});
  final WalletEntity wallet;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const UserWalletSectionCardHeader(),
          const SizedBox(height: 20),
          WalletInfoWrapCards(wallet: wallet),
          const Divider(height: 40, thickness: 1.2),
          CustomInfoRow(
            label: "معرف المحفظة (ID)",
            value: wallet.walletId.toString(),
            icon: Icons.fingerprint_rounded,
          ),
          const SizedBox(height: 12),
          CustomInfoRow(
            label: "تاريخ الانشاء",
            value: wallet.createdAt,
            icon: Icons.event_available_outlined,
          ),
          const SizedBox(height: 12),
          CustomInfoRow(
            label: "أخر تحديث",
            value: wallet.updatedAt,
            icon: Icons.published_with_changes_rounded,
          ),
          const SizedBox(height: 12),
          CustomInfoRow(
            label: "أخر تحويل",
            value: wallet.lastTransactionId.toString(),
            icon: FontAwesomeIcons.moneyBillTransfer,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
