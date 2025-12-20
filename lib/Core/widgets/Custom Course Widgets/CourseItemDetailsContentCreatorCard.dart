import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/ContentCreaterEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/Custom%20Course%20Widgets/CustomContentCreatorCircleAvartar.dart';

class CourseItemDetailsContentCreatorCard extends StatelessWidget {
  const CourseItemDetailsContentCreatorCard({
    super.key,
    required this.contentcreaterentity,
  });

  final Contentcreaterentity contentcreaterentity;

  @override
  Widget build(BuildContext context) {
    final styles = AppTextStyles(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white24 : Colors.grey.shade100,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.shade100,
            blurRadius: 7,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          CustomContentCreatorCircleAvartar(
            imagepath: contentcreaterentity.profileImageUrl,
          ),
          const SizedBox(width: 10),
          Text(
            contentcreaterentity.name,
            maxLines: 2,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: styles.semiBold12.copyWith(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.arrow_forward_ios,
            color: isDark ? Colors.white54 : Colors.grey.shade400,
            size: 15,
          ),
        ],
      ),
    );
  }
}
