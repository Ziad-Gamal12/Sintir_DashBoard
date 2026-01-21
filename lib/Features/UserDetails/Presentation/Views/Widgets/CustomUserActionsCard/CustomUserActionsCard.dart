import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserActionsCard/DelelteUserActionButton.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserActionsCard/EditUserDetailsButton.dart';

class CustomUserActionsCard extends StatelessWidget {
  const CustomUserActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    AppTextStyles textStyles = AppTextStyles(context);
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("إجراءات إدارية", style: textStyles.semiBold16),
          const SizedBox(height: 16),
          EditUserDetailsButton(),
          const SizedBox(height: 12),
          DelelteUserActionButton(),
        ],
      ),
    );
  }
}
