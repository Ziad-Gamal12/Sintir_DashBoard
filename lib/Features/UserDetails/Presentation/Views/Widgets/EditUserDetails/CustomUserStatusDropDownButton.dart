import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAnimatedDropDownButton.dart';

class CustomUserStatusDropDownButton extends StatefulWidget {
  const CustomUserStatusDropDownButton({
    super.key,
    this.hint,
    required this.onChanged,
  });
  final String? hint;
  final void Function(String?) onChanged;
  @override
  State<CustomUserStatusDropDownButton> createState() =>
      _CustomUserStatusDropDownButtonState();
}

class _CustomUserStatusDropDownButtonState
    extends State<CustomUserStatusDropDownButton> {
  List<String> items = [
    BackendEndpoints.activeStatus,
    BackendEndpoints.pendingStatus,
    BackendEndpoints.inActiveStatus,
    BackendEndpoints.rejectedStatus,
    BackendEndpoints.blockedStatus,
  ];
  @override
  Widget build(BuildContext context) {
    return CustomAnimatedDropDownButton(
      items: items,
      hintText: widget.hint ?? "حالة المستخدم",
      onChanged: widget.onChanged,
    );
  }
}
