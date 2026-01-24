import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/constant.dart';

class UserWalletSectionCardHeader extends StatelessWidget {
  const UserWalletSectionCardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(FontAwesomeIcons.wallet, color: KMainColor, size: 22),
        const SizedBox(width: 12),
        Text("المحفظة", style: AppTextStyles(context).semiBold16),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.edit, color: Colors.grey),
        ),
      ],
    );
  }
}
