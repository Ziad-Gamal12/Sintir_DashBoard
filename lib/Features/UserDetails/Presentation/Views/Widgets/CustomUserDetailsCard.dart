import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserAvatar.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserMainInfo.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserStatusActionSection.dart';

class CustomUserDetailsCard extends StatelessWidget {
  const CustomUserDetailsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Breakpoint for switching from Row to Column (e.g., 600px)
        bool isMobile = constraints.maxWidth < 600;

        return CustomCard(
          padding: const EdgeInsets.all(24),
          child: Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: isMobile
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              // 1. Avatar
              const UserAvatar(
                imageUrl:
                    "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?...",
              ),

              const SizedBox(width: 24, height: 24),
              Flexible(
                flex: isMobile ? 0 : 6,
                child: UserMainInfo(
                  textAlign: isMobile ? TextAlign.center : TextAlign.start,
                ),
              ),

              if (isMobile)
                const SizedBox(height: 24)
              else
                const Spacer(flex: 1),

              const UserStatusActionSection(),
            ],
          ),
        );
      },
    );
  }
}
