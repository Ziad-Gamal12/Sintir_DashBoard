import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/CustomUserInfoCard/UserDetailsStatusBadge.dart';
import 'package:sintir_dashboard/constant.dart';

class UserStatusActionSection extends StatelessWidget {
  const UserStatusActionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isNarrow = constraints.maxWidth < 600;
        return Wrap(
          direction: isNarrow ? Axis.horizontal : Axis.vertical,
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const UserDetailsStatusBadge(text: "مفعل", color: Colors.green),
            UserDetailsStatusBadge(text: "طالب", color: KMainColor),
          ],
        );
      },
    );
  }
}
