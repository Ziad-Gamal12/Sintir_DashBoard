import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomCourseSectionsCardHeader extends StatelessWidget {
  const CustomCourseSectionsCardHeader({
    super.key,
    required this.title,
    required this.showMore,
  });
  final String title;
  final VoidCallback showMore;
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles(
            context,
          ).semiBold20.copyWith(color: theme.textTheme.bodyLarge!.color),
        ),
        const Spacer(),
        TextButton(
          onPressed: showMore,
          child: Text(
            "اظهار المزيد",
            style: AppTextStyles(context).regular10.copyWith(color: KMainColor),
          ),
        ),
      ],
    );
  }
}
