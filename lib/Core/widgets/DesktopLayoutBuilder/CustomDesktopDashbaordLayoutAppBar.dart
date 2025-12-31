import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/imageAssets.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomToggleThemeIconButton.dart';
import 'package:svg_flutter/svg.dart';

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
              SvgPicture.asset(
                Assets.assetsIconsSVGIconsAppLogo,
                height: 40,
                width: 40,
              ),
              const SizedBox(width: 12),
              Text("لوحة التحكم ", style: AppTextStyles(context).semiBold20),

              Spacer(),
              CustomToggleThemeIconButton(),
            ],
          ),
          Divider(height: 32),
        ],
      ),
    );
  }
}
