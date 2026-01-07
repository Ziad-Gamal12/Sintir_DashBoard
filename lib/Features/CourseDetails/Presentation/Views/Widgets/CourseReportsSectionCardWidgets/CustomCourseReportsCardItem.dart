import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sintir_dashboard/Core/Entities/CourseReportsItemEntity.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CustomCourseReportsCardItem extends StatelessWidget {
  final CourseReportEntity report;
  const CustomCourseReportsCardItem({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyles = AppTextStyles(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Fix: Using Flexible to prevent overflow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.redAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          report.type,
                          overflow:
                              TextOverflow.ellipsis, // Prevents overflow error
                          style: textStyles.bold14.copyWith(
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8), // Gap between tag and date
              Text(
                DateFormat('yyyy/MM/dd').format(report.date),
                style: textStyles.regular13.copyWith(
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Sub-header with a small indicator line for premium feel
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "تفاصيل البلاغ:",
                style: textStyles.bold14.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            report.description,
            style: textStyles.regular14.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.85),
              height: 1.6,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
