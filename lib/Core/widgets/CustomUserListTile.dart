import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCachedNetworkImage.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomUserListTile extends StatelessWidget {
  const CustomUserListTile({super.key, required this.userEntity});

  final UserEntity userEntity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
        ), // Tighter padding
        leading: Container(
          padding: const EdgeInsets.all(2), // Space for the ring
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: KMainColor.withOpacity(0.4), width: 1.5),
          ),
          child: Container(
            width: 42, // Slightly smaller for elegance
            height: 42,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: CustomCachedNetworkImage(
                imageUrl: userEntity.profilePicurl,
              ),
            ),
          ),
        ),
        title: Text(
          userEntity.fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles(context).semiBold14.copyWith(
            color: isDark ? Colors.white : Colors.black,
            letterSpacing: 0.2,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              getRoleAr(),
              style: AppTextStyles(context).regular13.copyWith(
                color: isDark ? Colors.white54 : Colors.grey.shade600,
                fontSize: 11, // Smaller role text for hierarchy
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getRoleAr() {
    final roles = {
      BackendEndpoints.teacherRole: "معلم",
      BackendEndpoints.studentRole: "طالب",
      BackendEndpoints.coursesManagerrRole: "مدير محتوى",
      BackendEndpoints.usersManagerrRole: "مدير مستخدمين",
      BackendEndpoints.supportRole: "دعم فني",
      BackendEndpoints.adminRole: "مدير عام",
    };
    return roles[userEntity.role] ?? "مستخدم";
  }
}
