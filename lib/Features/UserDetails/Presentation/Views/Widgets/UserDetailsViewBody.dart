import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Helper/AppPadding.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserDetailsCard.dart';

class UserDetailsViewBody extends StatelessWidget {
  const UserDetailsViewBody({super.key, required this.userId});
  final String userId;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.horizontal(context),
        vertical: AppPadding.vertical(context),
      ),
      child: CustomScrollView(
        slivers: [SliverToBoxAdapter(child: CustomUserDetailsCard())],
      ),
    );
  }
}
