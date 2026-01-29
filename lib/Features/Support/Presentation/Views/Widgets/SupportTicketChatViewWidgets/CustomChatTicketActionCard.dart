import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Helper/GetUserData.dart';
import 'package:sintir_dashboard/Core/Permissions/Permissions%20Mapping.dart';
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
    final user = getUserData();
    final isMobile = MediaQuery.of(context).size.width < 600;

    final bool canChangeStatus = PermissionsManager.can(
      Permission.changeTicketStatus,
      role: user.role,
      status: user.status,
    );

    final bool canDelete = PermissionsManager.can(
      Permission
          .deleteUser, // Using deleteUser or a generic delete permission as per your Enum
      role: user.role,
      status: user.status,
    );

    if (!canChangeStatus && !canDelete) {
      return const SizedBox.shrink();
    }

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
                if (canChangeStatus)
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      width: 120,
                      child: CustomChangeTicketStatusDropDownButton(
                        currentStatus: currentStatus,
                        onChanged: onStatusChanged,
                      ),
                    ),
                  ),
                if (canChangeStatus && canDelete) const SizedBox(width: 12),
                if (canDelete)
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
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canChangeStatus)
                  CustomChangeTicketStatusDropDownButton(
                    currentStatus: currentStatus,
                    onChanged: onStatusChanged,
                  ),
                if (canChangeStatus && canDelete) const SizedBox(height: 12),
                if (canDelete)
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
