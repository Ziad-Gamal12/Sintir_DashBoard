import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserActionsCard/CustomUserActionsCard.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserFullDetailsCard.dart/CustomUseDetailsCard.dart';

class SlidingUserDetailsAndActionsCards extends StatelessWidget {
  const SlidingUserDetailsAndActionsCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomUserDetailsCard(),
        const SizedBox(height: 32),
        CustomUserActionsCard(),
      ],
    );
  }
}
