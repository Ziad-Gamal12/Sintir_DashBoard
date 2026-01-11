import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/imageAssets.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:svg_flutter/svg.dart';

class CustomSearchTextField extends StatelessWidget {
  const CustomSearchTextField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color surfaceColor = isDark ? theme.cardColor : Colors.white;
    final Color borderColor = isDark ? Colors.white10 : const Color(0xFFE4E6E8);
    final Color primaryColor = theme.primaryColor;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14), // Modern rounded corners
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles(
          context,
        ).semiBold14.copyWith(color: isDark ? Colors.white : Colors.black87),
        cursorColor: primaryColor,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          prefixIconConstraints: const BoxConstraints(minWidth: 50),
          hintText: "أبحث عن ...",
          hintStyle: AppTextStyles(
            context,
          ).regular14.copyWith(color: theme.hintColor.withOpacity(0.5)),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: SvgPicture.asset(
              Assets.assetsIconsSVGIconsSearchIcon,
              width: 18,
              height: 18,
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white54 : Colors.grey.shade400,
                BlendMode.srcIn,
              ),
            ),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    controller.clear();
                    if (onChanged != null) onChanged!("");
                  },
                )
              : null,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
