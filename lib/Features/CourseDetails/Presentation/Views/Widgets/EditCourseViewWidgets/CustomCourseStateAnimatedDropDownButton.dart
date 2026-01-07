import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAnimatedDropDownButton.dart';

class CustomCourseStateAnimatedDropDownButton extends StatefulWidget {
  const CustomCourseStateAnimatedDropDownButton({
    super.key,
    this.hintText,
    required this.onChanged,
  });
  final String? hintText;
  final void Function(String?) onChanged;
  @override
  State<CustomCourseStateAnimatedDropDownButton> createState() =>
      _CustomCourseStateAnimatedDropDownButtonState();
}

class _CustomCourseStateAnimatedDropDownButtonState
    extends State<CustomCourseStateAnimatedDropDownButton> {
  List<String> courseStates = [
    BackendEndpoints.coursePublishedState,
    BackendEndpoints.coursePendingState,
    BackendEndpoints.coursedeclinedState,
    BackendEndpoints.courseArchivedState,
    BackendEndpoints.courseDeletedByAdminState,
  ];
  @override
  Widget build(BuildContext context) {
    return CustomAnimatedDropDownButton(
      hintText: widget.hintText ?? "اختر حالة الدورة",
      items: courseStates,
      onChanged: widget.onChanged,
    );
  }
}
