import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/SlidingUserDetailsAndActionsCards.dart';

import 'UserDetailsMainContent.dart';

class UserDetailsMobileLayout extends StatelessWidget {
  const UserDetailsMobileLayout({super.key, required this.userID});
final String userID;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserDetailsMainContent(),
        SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: SlidingUserDetailsAndActionsCards(
            userID: userID,
          ),
        ),
      ],
    );
  }
}
