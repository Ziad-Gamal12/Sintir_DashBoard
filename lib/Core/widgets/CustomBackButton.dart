import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Utils/imageAssets.dart';
import 'package:svg_flutter/svg.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, this.onTap, this.color});

  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap ?? () => GoRouter.of(context).pop(),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            Assets.assetsIconsSVGIconsArrowLeftBack,
            height: 26, // Visual size
            width: 26,
            colorFilter: ColorFilter.mode(theme.primaryColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
