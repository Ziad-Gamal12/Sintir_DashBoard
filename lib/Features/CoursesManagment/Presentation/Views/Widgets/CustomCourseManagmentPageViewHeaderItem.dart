import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Domain/Entities/PageViewHeaderOptionsEntity.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Presentation/Views/Widgets/PageViewItemHeaderFooter.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomCourseManagmentPageViewHeaderItem extends StatelessWidget {
  const CustomCourseManagmentPageViewHeaderItem({
    super.key,
    required this.footerCount,
    required this.isSelected,
    required this.entity,
  });
  final int footerCount;
  final bool isSelected;
  final PageViewHeaderOptionsEntity entity;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              entity.iconData,
              size: 28,
              color: isSelected ? KMainColor : Colors.grey,
            ),
            SizedBox(width: 12),
            Text(
              entity.title,
              style: AppTextStyles(context).semiBold14.copyWith(
                color: isSelected ? KMainColor : Colors.grey,
              ),
            ),
            SizedBox(width: 8),
            PageViewItemHeaderFooter(
              isSelected: isSelected,
              footerBgColor: entity.footerBgColor,
              footerCount: footerCount,
            ),
          ],
        ),

        SizedBox(height: 8),
        Container(
          height: 4,
          width: 200,
          decoration: BoxDecoration(
            color: isSelected ? KMainColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }
}
