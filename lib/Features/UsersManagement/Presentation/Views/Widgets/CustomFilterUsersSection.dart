import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/FilterOptionEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAnimatedDropDownButton.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomSearchTextField.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Domain/Entities/FilterUsersQueryEntity.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Domain/Entities/UsersFilterConstants.dart';

class CustomFilterUsersSection extends StatefulWidget {
  const CustomFilterUsersSection({super.key, required this.onFilter});
  final Function(FilterUsersQueryEntity) onFilter;
  @override
  State<CustomFilterUsersSection> createState() =>
      _CustomFilterUsersSectionState();
}

class _CustomFilterUsersSectionState extends State<CustomFilterUsersSection> {
  final TextEditingController searchController = TextEditingController();
  FilterUsersQueryEntity filters = FilterUsersQueryEntity();
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
                      filters = FilterUsersQueryEntity();
                    });
                    widget.onFilter(filters);
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text("إعادة ضبط"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: 12,
              children: [
                _buildSearchField(),
                const SizedBox(width: 24),
                _buildFilterDropdown(
                  hint: "الدور",
                  options: UsersFilterConstants.getRolesFilters(),
                  onChanged: (valEn) {
                    setState(() {
                      filters.role = valEn;
                    });
                    widget.onFilter(filters);
                  },
                ),
                const SizedBox(width: 12),
                _buildFilterDropdown(
                  hint: "الحالة",
                  options: UsersFilterConstants.getUsersStatusFilters(),
                  onChanged: (valEn) {
                    setState(() {
                      filters.status = valEn;
                    });
                    widget.onFilter(filters);
                  },
                ),
                const SizedBox(width: 12),
                _buildFilterDropdown(
                  hint: "الجنس",
                  options: UsersFilterConstants.getGenderFilters(),
                  onChanged: (valEn) {
                    setState(() {
                      filters.gender = valEn;
                    });
                    widget.onFilter(filters);
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
            filters.keyword = value.trim();
          });
          widget.onFilter(filters);
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
