import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Core/widgets/CustomInfoRow.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/TeacherWalletEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Domain/Helpers/UserWalletStatusHelper.dart';

class UserWalletSectionCardDetailInfo extends StatelessWidget {
  final WalletEntity wallet;

  const UserWalletSectionCardDetailInfo({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        CustomInfoRow(
          label: "معرف المحفظة (ID)",
          value: wallet.walletId.toString(),
          icon: Icons.fingerprint_rounded,
        ),
        CustomInfoRow(
          label: "تاريخ الانشاء",
          value: wallet.createdAt,
          icon: Icons.event_available_outlined,
        ),
        CustomInfoRow(
          label: "حالة المحفظة",
          value: UserWalletStatusHelper.getUserWalletStatusArabic(
            wallet.status,
          ),
          icon: Icons.account_balance_wallet_outlined,
        ),
        CustomInfoRow(
          label: "أخر تحديث",
          value: wallet.updatedAt,
          icon: Icons.published_with_changes_rounded,
        ),
        CustomInfoRow(
          label: "أخر تحويل",
          value: wallet.lastTransactionId.toString(),
          icon: FontAwesomeIcons.moneyBillTransfer,
        ),
      ],
    );
  }
}
