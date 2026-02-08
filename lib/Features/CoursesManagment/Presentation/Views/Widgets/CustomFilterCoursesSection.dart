import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/FilterCoursesQueryEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FilterOptionEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAnimatedDropDownButton.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomSearchTextField.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Domain/Entities/CourseFilterConstants.dart';

class CustomFilterCoursesSection extends StatefulWidget {
  const CustomFilterCoursesSection({super.key, required this.onFilterChanged});
  final Function(FilterCoursesQueryEntity) onFilterChanged;
  @override
  State<CustomFilterCoursesSection> createState() =>
      _CustomFilterCoursesSectionState();
}

class _CustomFilterCoursesSectionState
    extends State<CustomFilterCoursesSection> {
  final TextEditingController searchController = TextEditingController();
  FilterCoursesQueryEntity filters = FilterCoursesQueryEntity();
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  "تصفية النتائج",
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      filters = FilterCoursesQueryEntity();
                    });
                    widget.onFilterChanged(filters);
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text("إعادة ضبط"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 4,
              runSpacing: 4,
              children: [
                _buildSearchField(),
                const SizedBox(width: 24),
                _buildFilterDropdown(
                  hint: "المادة الدراسية",
                  options: CourseFilterConstants.getSubjectFilters(),
                  onChanged: (valEn) {
                    setState(() {
                      filters.subject = valEn;
                    });
                    widget.onFilterChanged(filters);
                  },
                ),
                const SizedBox(width: 12),

                // 3. Level Filter
                _buildFilterDropdown(
                  hint: "المستوى الدراسي",
                  options: CourseFilterConstants.getLevelFilters(),
                  onChanged: (valEn) {
                    setState(() {
                      filters.level = valEn;
                    });
                    widget.onFilterChanged(filters);
                  },
                ),
                const SizedBox(width: 12),

                // 4. Status Filter
                _buildFilterDropdown(
                  hint: "حالة الكورس",
                  options: CourseFilterConstants.getStatusFilters(),
                  onChanged: (valEn) {
                    setState(() {
                      filters.state = valEn;
                    });
                    widget.onFilterChanged(filters);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      width: 350,
      height: 48,
      child: CustomSearchTextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            filters.title = value.trim();
          });
          widget.onFilterChanged(filters);
        },
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String hint,
    required List<FilterOptionEntity> options,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 200,
          height: 48,
          child: CustomAnimatedDropDownButton(
            items: options.map((e) => e.labelAr).toList(),
            hintText: hint,
            onChanged: (selectedLabelAr) {
              final selectedEnValue = options
                  .firstWhere((e) => e.labelAr == selectedLabelAr)
                  .valueEn;
              onChanged(selectedEnValue);
            },
          ),
        ),
      ],
    );
  }
}
