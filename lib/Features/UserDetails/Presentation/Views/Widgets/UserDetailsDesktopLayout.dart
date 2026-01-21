import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/SlidingUserDetailsAndActionsCards.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserDetailsMainContent.dart';

class UserDetailsDesktopLayout extends StatelessWidget {
  const UserDetailsDesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(flex: 7, child: UserDetailsMainContent()),
        const SizedBox(width: 32),
        Expanded(flex: 3, child: SlidingUserDetailsAndActionsCards()),
      ],
    );
  }
}
