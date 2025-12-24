import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Features/Dashboard/Presentation/Views/Widgets/CustomGenderColoredCard.dart';

class CustomGenderSummaryInfo extends StatelessWidget {
  const CustomGenderSummaryInfo({
    super.key,
    required this.femaleCount,
    required this.maleCount,
  });

  final int femaleCount;
  final int maleCount;

  @override
  Widget build(BuildContext context) {
    // Using Wrap instead of Row for better responsiveness
    return Wrap(
      spacing: 24,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildGenderItem(
          context,
          label: "ذكور",
          count: maleCount,
          color: const Color(0xff2196F3),
        ),
        _buildGenderItem(
          context,
          label: "إناث",
          count: femaleCount,
          color: const Color(0xffE91E63),
        ),
      ],
    );
  }

  Widget _buildGenderItem(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomGenderColoredCard(color: color),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles(
                context,
              ).regular14.copyWith(color: Colors.grey),
            ),
            Text(count.toString(), style: AppTextStyles(context).semiBold16),
          ],
        ),
      ],
    );
  }
}
