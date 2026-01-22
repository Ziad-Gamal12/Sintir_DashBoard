// lib/Features/TicketsManagement/Presentation/Views/Widgets/TicketSenderInfo.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';
import 'package:sintir_dashboard/Core/widgets/UsersTableWidgets/UserRole.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportSenderEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/ResponsiveUserDetailsView.dart';

class TicketSenderInfo extends StatelessWidget {
  final SupportSenderEntity sender;
  const TicketSenderInfo({super.key, required this.sender});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        GoRouter.of(
          context,
        ).push(ResponsiveUserDetailsView.routeName, extra: sender.uid);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.antiAlias,
            child: CustomCachedNetworkImage(imageUrl: sender.photoUrl),
          ),
          const SizedBox(width: 10),

          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sender.name.isEmpty ? "مستخدم مجهول" : sender.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sender.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          UserRole(role: sender.role),
        ],
      ),
    );
  }
}
