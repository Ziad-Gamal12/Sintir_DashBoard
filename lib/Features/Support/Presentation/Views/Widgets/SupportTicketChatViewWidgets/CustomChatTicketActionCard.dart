import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/AdaptiveActionButton.dart';
import 'package:sintir_dashboard/Features/Support/Presentation/Views/Widgets/SupportTicketChatViewWidgets/CustomChangeTicketStatusDropDownButton.dart';

class CustomChatTicketActionCard extends StatelessWidget {
  const CustomChatTicketActionCard({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
    required this.onDeleteTicket,
    required this.isDeletingLoading,
  });

  final String currentStatus;
  final Function(String) onStatusChanged;
  final VoidCallback onDeleteTicket;
  final bool isDeletingLoading;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
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

                AdaptiveActionButton(
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

                AdaptiveActionButton(
                  isMobile: isMobile,
                  text: 'حذف',
                  icon: Icons.delete_outline_rounded,
                  color: Colors.red.withOpacity(0.1),
                  textColor: Colors.redAccent,
                  onPressed: onDeleteTicket,
                  isLoading: isDeletingLoading,
                ),
              ],
            ),
    );
  }
}
