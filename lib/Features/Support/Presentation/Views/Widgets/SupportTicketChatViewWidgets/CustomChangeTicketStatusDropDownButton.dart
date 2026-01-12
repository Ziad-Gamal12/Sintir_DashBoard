import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAnimatedDropDownButton.dart';
import 'package:sintir_dashboard/core/utils/backend_endpoints.dart';

class CustomChangeTicketStatusDropDownButton extends StatefulWidget {
  const CustomChangeTicketStatusDropDownButton({
    super.key,
    required this.onChanged,
    required this.currentStatus,
  });
  final Function(String) onChanged;
  final String currentStatus;
  @override
  State<CustomChangeTicketStatusDropDownButton> createState() =>
      _CustomChangeTicketStatusDropDownButtonState();
}

class _CustomChangeTicketStatusDropDownButtonState
    extends State<CustomChangeTicketStatusDropDownButton> {
  List<String> items = [
    BackendEndpoints.open,
    BackendEndpoints.pending,
    BackendEndpoints.inProgress,
    BackendEndpoints.highPriority,
    BackendEndpoints.urgent,
    BackendEndpoints.resolved,
    BackendEndpoints.closed,
  ];

  @override
  Widget build(BuildContext context) {
    return CustomAnimatedDropDownButton(
      items: items,
      hintText: widget.currentStatus,
      onChanged: (val) {
        widget.onChanged(val ?? widget.currentStatus);
      },
    );
  }
}
