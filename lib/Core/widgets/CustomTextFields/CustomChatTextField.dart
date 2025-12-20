import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomChatTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback onPressed;
  final void Function(String?)? onSaved;
  final bool isLoading;

  const CustomChatTextField({
    super.key,
    this.inputFormatters,
    required this.onPressed,
    this.isLoading = false,
    this.onSaved,
    required this.controller,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(24),
    );
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        inputFormatters: inputFormatters,
        controller: controller,
        onSaved: onSaved,
        validator: validator,
        maxLines: 5,
        minLines: 1,
        style: AppTextStyles(
          context,
        ).bold13.copyWith(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          hintText: " اكتب الرسالة",
          hintStyle: AppTextStyles(
            context,
          ).bold13.copyWith(color: Colors.grey.shade400),
          filled: true,
          fillColor: Colors.transparent,
          border: border,
          focusedBorder: border,
          enabledBorder: border,
          suffixIcon: _buildSuffixIcon(),
        ),
      ),
    );
  }

  Widget _buildSuffixIcon() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: KMainColor),
        ),
      );
    }

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final bool isNotEmpty = value.text.trim().isNotEmpty;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            key: ValueKey<bool>(isNotEmpty),
            icon: Icon(
              FontAwesomeIcons.paperPlane,
              size: 20,
              color: isNotEmpty ? KMainColor : Colors.grey.shade400,
            ),
            onPressed: isNotEmpty ? onPressed : null,
          ),
        );
      },
    );
  }
}
