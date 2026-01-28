import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomTeaxtField.dart';
import 'package:sintir_dashboard/Core/widgets/DatePickerField.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/TeacherWalletEntity.dart';

class UserWalletSectionCardDetailForm extends StatelessWidget {
  final WalletEntity wallet;
  final TextEditingController walletIdController;
  final TextEditingController lastTransactionIdController;
  final VoidCallback onDateChanged;

  const UserWalletSectionCardDetailForm({
    super.key,
    required this.wallet,
    required this.walletIdController,
    required this.lastTransactionIdController,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      children: [
        CustomTextField(
          hintText: "معرف المحفظة (ID)",
          controller: walletIdController,
          obscureText: false,
          prefixIcon: Icons.fingerprint_rounded,
          textInputType: TextInputType.number,
          onSaved: (value) => wallet.walletId = int.tryParse(value ?? "0") ?? 0,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "معرف المحفظة (ID) مطلوب";
            }
            if (value.length < 8) {
              return "معرف المحفظة (ID) يجب ان يكون على الاقل 8 حروف";
            }
            if (int.tryParse(value) == null) return "يجب استخدام ارقام فقط";
            return null;
          },
        ),
        DatePickerField(
          initialDate: wallet.createdAt,
          onDateChanged: (value) {
            wallet.createdAt = value.toString();
            onDateChanged();
          },
        ),
        CustomTextField(
          hintText: "اخر تحويل",
          prefixIcon: FontAwesomeIcons.moneyBillTransfer,
          controller: lastTransactionIdController,
          obscureText: false,
          textInputType: TextInputType.number,
          onSaved: (value) => wallet.lastTransactionId = value.toString(),
          validator: (value) => null,
        ),
      ],
    );
  }
}
