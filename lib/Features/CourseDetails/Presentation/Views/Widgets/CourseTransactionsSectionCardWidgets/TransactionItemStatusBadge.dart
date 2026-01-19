import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class TransactionItemStatusBadge extends StatefulWidget {
  const TransactionItemStatusBadge({super.key, required this.status});
  final String? status;
  @override
  State<TransactionItemStatusBadge> createState() =>
      _TransactionItemStatusBadgeState();
}

class _TransactionItemStatusBadgeState
    extends State<TransactionItemStatusBadge> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(widget.status ?? "pending").withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(widget.status ?? "pending").withOpacity(0.2),
        ),
      ),
      child: Text(
        _getStatusLabel(widget.status ?? "pending"),
        style: AppTextStyles(context).semiBold12.copyWith(
          color: _getStatusColor(widget.status ?? "pending"),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return "ناجحة";
      case 'failed':
        return "فاشلة";
      default:
        return "معلقة";
    }
  }
}
