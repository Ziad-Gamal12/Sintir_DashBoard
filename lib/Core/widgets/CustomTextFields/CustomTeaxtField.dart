import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType textInputType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String?)? onSaved;
  final int maxLines;

  const CustomTextField({
    super.key,
    this.inputFormatters,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    required this.obscureText,
    this.controller,
    required this.textInputType,
    required this.validator,
    this.onSaved,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final Color borderColor = isDarkMode
        ? Colors.white10
        : const Color(0xFFE4E6E8);
    final Color fillBg = isDarkMode
        ? Colors.white.withOpacity(0.02)
        : const Color(0xFFF8F9FA);

    return TextFormField(
      onSaved: onSaved,
      inputFormatters: inputFormatters,
      controller: controller,
      keyboardType: textInputType,
      obscureText: obscureText,
      validator: validator,
      maxLines: maxLines,
      style: AppTextStyles(
        context,
      ).semiBold14.copyWith(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles(
          context,
        ).regular14.copyWith(color: theme.hintColor.withOpacity(0.5)),

        filled: true,
        fillColor: fillBg,
        prefixIcon: prefixIcon != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  prefixIcon,
                  size: 20,
                  color: theme.primaryColor.withOpacity(0.7),
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),

        suffixIcon: suffixIcon,

        // Modern Borders
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: .75),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: KMainColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),

        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
      ),
    );
  }
}
