// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/imageAssets.dart';
import 'package:sintir_dashboard/constant.dart';
import 'package:svg_flutter/svg.dart';

class Customcheckbox extends StatefulWidget {
  final ValueChanged<bool> onChanged;
  const Customcheckbox({super.key, required this.onChanged});

  @override
  State<Customcheckbox> createState() => _CustomcheckboxState();
}

class _CustomcheckboxState extends State<Customcheckbox> {
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        isChecked = !isChecked;
        setState(() {});
        widget.onChanged(isChecked);
      },
      child: AnimatedContainer(
        alignment: Alignment.center,
        duration: const Duration(milliseconds: 300),
        height: 24,
        width: 24,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1.50,
              color: getBorderColor(isDark: isDarkMode),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          color: getFilledColor(isDark: isDarkMode),
        ),
        child: isChecked
            ? SvgPicture.asset(Assets.assetsIconsSVGIconsCheckedIcon)
            : const SizedBox(),
      ),
    );
  }

  Color getFilledColor({required bool isDark}) {
    if (isChecked) {
      return KMainColor;
    } else {
      if (isDark) {
        return const Color(0xFF2A2A2A);
      } else {
        return Colors.white;
      }
    }
  }

  Color getBorderColor({required bool isDark}) {
    if (isChecked) {
      return Colors.transparent;
    } else {
      if (isDark) {
        return const Color(0xFF2A2A2A);
      } else {
        return const Color(0xFFDCDEDE);
      }
    }
  }
}
