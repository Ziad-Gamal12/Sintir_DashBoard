import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAnimatedDropDownButton.dart';

class CustomLanguageDropdownButton extends StatefulWidget {
  const CustomLanguageDropdownButton({
    super.key,
    required this.onValueChange,
    required this.hintText,
  });
  final ValueChanged<String?> onValueChange;
  final String? hintText;
  @override
  State<CustomLanguageDropdownButton> createState() =>
      _CustomLanguageDropdownButtonState();
}

class _CustomLanguageDropdownButtonState
    extends State<CustomLanguageDropdownButton> {
  List<String> items = ["العربية", "English", "أخرى"];
  @override
  Widget build(BuildContext context) {
    return CustomAnimatedDropDownButton(
      hintText: widget.hintText ?? "لغة الدورة",
      items: items,
      onChanged: widget.onValueChange,
    );
  }
}
