import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class SelectUserRoleHeader extends StatelessWidget {
  const SelectUserRoleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text("نوع الحساب", style: AppTextStyles(context).semiBold16);
  }
}
