import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAnimatedDropDownButton.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomSearchTextField.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Domain/Entities/CourseFilterConstants.dart';
import 'package:sintir_dashboard/Features/CoursesManagment/Domain/Entities/FilterOptionEntity.dart';

class CustomFilterCoursesSection extends StatefulWidget {
  const CustomFilterCoursesSection({super.key});

  @override
  State<CustomFilterCoursesSection> createState() =>
      _CustomFilterCoursesSectionState();
}

class _CustomFilterCoursesSectionState
    extends State<CustomFilterCoursesSection> {
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
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
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text("إعادة ضبط"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Search Bar - Increased width for prominence
                  _buildSearchField(),
                  const SizedBox(width: 24),

                  // 2. Subject Filter
                  _buildFilterDropdown(
                    hint: "المادة الدراسية",
                    options: CourseFilterConstants.getSubjectFilters(),
                    onChanged: (valEn) => print("Selected Subject: $valEn"),
                  ),
                  const SizedBox(width: 12),

                  // 3. Level Filter
                  _buildFilterDropdown(
                    hint: "المستوى الدراسي",
                    options: CourseFilterConstants.getLevelFilters(),
                    onChanged: (valEn) => print("Selected Level: $valEn"),
                  ),
                  const SizedBox(width: 12),

                  // 4. Status Filter
                  _buildFilterDropdown(
                    hint: "حالة الكورس",
                    options: CourseFilterConstants.getStatusFilters(),
                    onChanged: (valEn) => print("Selected Status: $valEn"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      width: 350, // Slightly reduced to fit more on screen
      height: 48,
      child: CustomSearchTextField(
        controller: searchController,
        onChanged: (value) {},
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
          height: 48, // Match search field height for perfect alignment
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
