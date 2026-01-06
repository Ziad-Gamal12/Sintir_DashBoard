import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAnimatedDropDownButton.dart';

class CustomSubjectDropdownButton extends StatefulWidget {
  const CustomSubjectDropdownButton({
    super.key,
    required this.onValueChange,
    required this.hintText,
  });
  final ValueChanged<String?> onValueChange;
  final String? hintText;
  @override
  State<CustomSubjectDropdownButton> createState() =>
      _CustomSubjectDropdownButtonState();
}

class _CustomSubjectDropdownButtonState
    extends State<CustomSubjectDropdownButton> {
  List<String> items = [
    "Arabic",
    "English",
    "French",
    "Italian",
    "Spanish",
    "Mathematics",
    "Physics",
    "Chemistry",
    "Biology",
    "Biological Science",
    "Science",
    "Philosophy",
    "History",
    "Geography",
    "Computer Science",
    "Other",
  ];
  @override
  Widget build(BuildContext context) {
    return CustomAnimatedDropDownButton(
      items: items,
      hintText: widget.hintText ?? "المادة الدراسية",
      onChanged: widget.onValueChange,
    );
  }
}
