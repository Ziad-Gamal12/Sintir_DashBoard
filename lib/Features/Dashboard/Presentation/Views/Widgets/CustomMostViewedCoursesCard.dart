import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomMostViewedCoursesTable.dart';

class CustomMostViewedCoursesCard extends StatefulWidget {
  const CustomMostViewedCoursesCard({super.key});

  @override
  State<CustomMostViewedCoursesCard> createState() =>
      _CustomMostViewedCoursesCardState();
}

class _CustomMostViewedCoursesCardState
    extends State<CustomMostViewedCoursesCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "أكثر الدورات مشاهدة",
            style: AppTextStyles(
              context,
            ).semiBold16.copyWith(color: theme.textTheme.bodyLarge!.color),
          ),
          const SizedBox(height: 24),
          CustomMostViewedCoursesTable(),
        ],
      ),
    );
  }
}
