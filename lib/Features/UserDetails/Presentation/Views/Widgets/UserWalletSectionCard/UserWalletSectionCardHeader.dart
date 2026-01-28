import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/constant.dart';

class UserWalletSectionCardHeader extends StatelessWidget {
  const UserWalletSectionCardHeader({
    super.key,
    required this.isEditingOnChanged,
    required this.isEditing,
    this.isLoading = false,
  });

  final void Function(bool) isEditingOnChanged;
  final bool isEditing;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(FontAwesomeIcons.wallet, color: KMainColor, size: 22),
        const SizedBox(width: 12),
        Text("المحفظة", style: AppTextStyles(context).semiBold16),
        const Spacer(),
        isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                onPressed: () => isEditingOnChanged(!isEditing),
                icon: Icon(
                  isEditing ? Icons.done : Icons.edit,
                  color: isEditing ? Colors.green : Colors.grey,
                ),
              ),
      ],
    );
  }
}
