import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserActionsCard/DelelteUserActionButton.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserActionsCard/EditUserDetailsButton.dart';

class CustomUserActionsCard extends StatelessWidget {
  const CustomUserActionsCard({super.key, required this.userID});
  final String userID;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditUserDetailsButton(),
        const SizedBox(height: 12),
        DelelteUserActionButton(userID: userID),
      ],
    );
  }
}
