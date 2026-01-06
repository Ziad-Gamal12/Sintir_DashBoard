import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomDateHeader.dart';
import 'package:sintir_dashboard/Core/widgets/CustomToggleThemeIconButton.dart';

class CustomDesktopDashbaordLayoutAppBar extends StatelessWidget {
  const CustomDesktopDashbaordLayoutAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  LucideIcons.layoutDashboard,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text("لوحة التحكم ", style: AppTextStyles(context).semiBold20),
              Spacer(),
              CustomDateHeader(date: DateTime.now()),
              const SizedBox(width: 24),
              CustomToggleThemeIconButton(),
            ],
          ),
          Divider(height: 32),
        ],
      ),
    );
  }
}
