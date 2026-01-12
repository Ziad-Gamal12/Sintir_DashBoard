import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/Custombutton.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/CustomChangeTicketStatusDropDownButton.dart';

class CustomChatTicketActionCard extends StatelessWidget {
  const CustomChatTicketActionCard({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
    required this.onLeaveChat,
    required this.onDeleteTicket,
  });

  final String currentStatus;
  final Function(String) onStatusChanged;
  final VoidCallback onLeaveChat;
  final VoidCallback onDeleteTicket;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    log(MediaQuery.of(context).size.width.toString());
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: isMobile
          ? Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    width: isMobile ? 120 : 200,
                    child: CustomChangeTicketStatusDropDownButton(
                      currentStatus: currentStatus,
                      onChanged: onStatusChanged,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                _buildActionButton(
                  context,
                  isMobile: isMobile,
                  text: 'مغادرة',
                  icon: Icons.logout_rounded,
                  color: Colors.amber.withOpacity(0.15),
                  textColor: Colors.amber[800]!,
                  onPressed: onLeaveChat,
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  context,
                  isMobile: isMobile,
                  text: 'حذف',
                  icon: Icons.delete_outline_rounded,
                  color: Colors.red.withOpacity(0.1),
                  textColor: Colors.redAccent,
                  onPressed: onDeleteTicket,
                ),
              ],
            )
          : Column(
              children: [
                CustomChangeTicketStatusDropDownButton(
                  currentStatus: currentStatus,
                  onChanged: onStatusChanged,
                ),
                const SizedBox(height: 12),

                _buildActionButton(
                  context,
                  isMobile: isMobile,
                  text: 'مغادرة',
                  icon: Icons.logout_rounded,
                  color: Colors.amber.withOpacity(0.15),
                  textColor: Colors.amber[800]!,
                  onPressed: onLeaveChat,
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  context,
                  isMobile: isMobile,
                  text: 'حذف',
                  icon: Icons.delete_outline_rounded,
                  color: Colors.red.withOpacity(0.1),
                  textColor: Colors.redAccent,
                  onPressed: onDeleteTicket,
                ),
              ],
            ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required bool isMobile,
    required String text,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    if (isMobile) {
      return Container(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: textColor, size: 20),
          tooltip: text,
        ),
      );
    }
    return Custombutton(
      text: text,
      color: color,
      textColor: textColor,
      onPressed: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
