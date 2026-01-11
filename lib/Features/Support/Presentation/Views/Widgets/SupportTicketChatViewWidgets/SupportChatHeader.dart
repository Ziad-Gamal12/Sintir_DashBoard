import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Entities/SupportSenderEntity.dart';

class SupportChatHeader extends StatelessWidget {
  final SupportSenderEntity sender;

  const SupportChatHeader({super.key, required this.sender});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildAvatar(),
          const SizedBox(width: 8),
          Text(
            sender.name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(width: 8),
          _buildRoleBadge(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return SizedBox(
      width: 32,
      height: 32,
      child: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: CustomCachedNetworkImage(imageUrl: sender.photoUrl),
        ),
      ),
    );
  }

  Widget _buildRoleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Text(
        sender.role.toLowerCase(),
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
