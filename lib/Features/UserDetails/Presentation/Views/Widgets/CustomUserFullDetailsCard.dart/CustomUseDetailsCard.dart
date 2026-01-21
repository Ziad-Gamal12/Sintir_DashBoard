import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Core/widgets/CustomInfoRow.dart';

class CustomUserDetailsCard extends StatelessWidget {
  const CustomUserDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    const String fullName = "أحمد محمد علي";
    const String email = "ahmed.ali@example.com";
    const String phoneNumber = "01012345678";
    const String address = "القاهرة، مدينة نصر";
    const String role = "مدرس (Teacher)";
    const String status = "نشط";
    final DateTime joinedDate = DateTime(2023, 10, 15);

    return CustomCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("تفاصيل المستخدم", style: AppTextStyles(context).semiBold20),
          const SizedBox(height: 25),
          CustomInfoRow(
            label: "الاسم بالكامل",
            value: fullName,
            icon: Icons.person_outline_rounded,
          ),
          _buildDivider(),

          CustomInfoRow(
            label: "البريد الإلكتروني",
            value: email,
            icon: Icons.email_outlined,
          ),
          _buildDivider(),

          CustomInfoRow(
            label: "رقم الهاتف",
            value: phoneNumber,
            icon: Icons.phone_android_rounded,
          ),
          _buildDivider(),

          CustomInfoRow(
            label: "العنوان",
            value: address,
            icon: Icons.location_on_outlined,
          ),
          _buildDivider(),

          CustomInfoRow(
            label: "الدور (Role)",
            value: role,
            icon: Icons.admin_panel_settings_outlined,
          ),
          _buildDivider(),

          CustomInfoRow(
            label: "الحالة",
            value: status,
            icon: Icons.info_outline_rounded,
          ),
          _buildDivider(),

          CustomInfoRow(
            label: "تاريخ الانضمام",
            value: DateFormat('yyyy/MM/dd').format(joinedDate),
            icon: Icons.calendar_today_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.05),
      thickness: 1,
      height: 20,
    );
  }
}
