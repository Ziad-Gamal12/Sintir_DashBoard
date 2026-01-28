import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/TeacherWalletEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserWalletSectionCard/CustomWalletInfoCard.dart';
import 'package:sintir_dashboard/constant.dart';

class WalletInfoWrapCards extends StatefulWidget {
  const WalletInfoWrapCards({
    super.key,
    required this.wallet,
    required this.isEditing,
  });
  final WalletEntity wallet;
  final bool isEditing;

  @override
  State<WalletInfoWrapCards> createState() => _WalletInfoWrapCardsState();
}

class _WalletInfoWrapCardsState extends State<WalletInfoWrapCards> {
  late TextEditingController currentBalanceValueController,
      totalEarnedValueController,
      payoutPending,
      currencyController;
  @override
  void initState() {
    super.initState();
    currentBalanceValueController = TextEditingController(
      text: widget.wallet.balance.toString(),
    );
    totalEarnedValueController = TextEditingController(
      text: widget.wallet.totalEarned.toString(),
    );
    payoutPending = TextEditingController(
      text: widget.wallet.payoutPending.toString(),
    );
    currencyController = TextEditingController(text: widget.wallet.currency);
  }

  @override
  void dispose() {
    super.dispose();
    currentBalanceValueController.dispose();
    totalEarnedValueController.dispose();
    payoutPending.dispose();
    currencyController.dispose();
  }

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
                isEditing: widget.isEditing,
                onValueChanged: (value) {
                  widget.wallet.balance = double.tryParse(value) ?? 0;
                },
                onCurrencyChanged: (value) {
                  widget.wallet.currency = value;
                },
                currencyController: currencyController,
                valueController: currentBalanceValueController,
                label: "الرصيد المتاح",
                currency: widget.wallet.currency,
                color: KMainColor,
                icon: Icons.account_balance_wallet_outlined,
                value: widget.wallet.balance.toString(),
              ),
            ),
            _buildResponsiveItem(
              constraints,
              CustomWalletInfoCard(
                isEditing: widget.isEditing,
                onValueChanged: (value) {
                  widget.wallet.totalEarned = double.tryParse(value) ?? 0;
                },
                onCurrencyChanged: (value) {
                  widget.wallet.currency = value;
                },
                currencyController: currencyController,
                valueController: totalEarnedValueController,
                label: "إجمالي الأرباح",
                currency: widget.wallet.currency,
                color: Colors.green,
                icon: Icons.trending_up_rounded,
                value: widget.wallet.totalEarned.toString(),
              ),
            ),
            _buildResponsiveItem(
              constraints,
              CustomWalletInfoCard(
                isEditing: widget.isEditing,
                onValueChanged: (value) {
                  widget.wallet.payoutPending = double.tryParse(value) ?? 0;
                },
                onCurrencyChanged: (value) {
                  widget.wallet.currency = value;
                },
                currencyController: currencyController,
                valueController: payoutPending,
                label: "المبالغ المعلقة",
                currency: widget.wallet.currency,
                color: Colors.orange,
                icon: Icons.hourglass_empty_rounded,
                value: widget.wallet.payoutPending.toString(),
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
