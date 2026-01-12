import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/Utils/imageAssets.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:svg_flutter/svg_flutter.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.appBartitle,
    this.showBackButton = false,
  });

  final String appBartitle;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: true,

      // 1. LEADING: Always show Drawer Icon (Main Navigation)
      leading: Center(
        child: IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.menu_rounded,
              color: isDarkMode ? Colors.white : Colors.black87,
              size: 22,
            ),
          ),
        ),
      ),

      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Text(appBartitle, style: AppTextStyles(context).bold19)],
      ),

      actions: [
        const SizedBox(width: 56),
        if (showBackButton) ...[
          _buildActionBack(context, isDarkMode, isRTL),
          const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _buildActionBack(BuildContext context, bool isDarkMode, bool isRTL) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
        child: RotatedBox(
          quarterTurns: isRTL ? 2 : 0,
          child: SvgPicture.asset(
            Assets.assetsIconsSVGIconsArrowLeftBack,
            height: 24,
            colorFilter: ColorFilter.mode(
              isDarkMode ? Colors.white : Colors.black54,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
