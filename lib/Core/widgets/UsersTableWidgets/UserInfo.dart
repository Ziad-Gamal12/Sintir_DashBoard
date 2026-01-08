import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';

class UserInfo extends StatelessWidget {
  const UserInfo({super.key, required this.user});
  final UserEntity user;
  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles(context);
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 48,
            height: 48,
            color: Colors.blue.withOpacity(0.1),
            child: CustomCachedNetworkImage(imageUrl: user.profilePicurl),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${user.firstName} ${user.lastName}",
                style: textStyles.semiBold14,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: textStyles.regular13.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
