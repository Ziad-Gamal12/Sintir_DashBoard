import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class Custombutton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback? onPressed;
  final BorderRadiusGeometry? borderRadius;
  final BorderSide? side;
  final Widget? child;
  final bool isLoading;
  final double? height;
  final double? width;

  const Custombutton({
    super.key,
    required this.text,
    this.borderRadius,
    this.child,
    this.side,
    this.isLoading = false,
    this.height,
    this.width,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 48,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          side: side ?? BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        onPressed: isLoading ? null : onPressed,
        child:
            child ??
            Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles(
                context,
              ).semiBold16.copyWith(color: textColor),
            ),
      ),
    );
  }
}
