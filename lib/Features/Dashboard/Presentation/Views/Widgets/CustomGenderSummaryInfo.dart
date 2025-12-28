import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CustomGenderSummaryInfo extends StatelessWidget {
  const CustomGenderSummaryInfo({
    super.key,
    required this.femaleCount,
    required this.maleCount,
  });

  final double femaleCount;
  final double maleCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildGenderCard(
            context,
            "ذكور",
            maleCount,
            const Color(0xff2196F3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGenderCard(
            context,
            "إناث",
            femaleCount,
            const Color(0xffE91E63),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderCard(
    BuildContext context,
    String label,
    double count,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles(
              context,
            ).regular14.copyWith(color: color.withOpacity(0.8)),
          ),
          const SizedBox(height: 4),
          Text(
            count.toInt().toString(),
            style: AppTextStyles(context).semiBold16,
          ),
        ],
      ),
    );
  }
}
