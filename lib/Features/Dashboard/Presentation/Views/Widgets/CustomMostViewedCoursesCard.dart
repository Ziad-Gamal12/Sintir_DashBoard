import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade100,
          width: 1,
        ),
      ),
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
