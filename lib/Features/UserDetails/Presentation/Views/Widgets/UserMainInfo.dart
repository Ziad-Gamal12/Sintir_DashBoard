import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserDetailsInfoTile.dart';

class UserMainInfo extends StatelessWidget {
  final TextAlign textAlign;
  const UserMainInfo({super.key, this.textAlign = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text("زياد محمد", style: AppTextStyles(context).bold24),
        const SizedBox(height: 12),
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            UserDetailsInfoTile(icon: Icons.email, label: "R5v9j@example.com"),
            UserDetailsInfoTile(icon: Icons.badge, label: "ID: 123456789"),
            UserDetailsInfoTile(icon: Icons.phone, label: "+123456789"),
            UserDetailsInfoTile(
              icon: Icons.calendar_month,
              label:
                  "تاريخ التسجيل: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}",
            ),
          ],
        ),
      ],
    );
  }
}
