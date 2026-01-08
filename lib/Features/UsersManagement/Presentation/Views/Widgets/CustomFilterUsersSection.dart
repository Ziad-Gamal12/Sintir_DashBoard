import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Entities/FilterOptionEntity.dart';
import 'package:sintir_dashboard/Core/widgets/CustomAnimatedDropDownButton.dart';
import 'package:sintir_dashboard/Core/widgets/CustomCard.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomSearchTextField.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Domain/Entities/UsersFilterConstants.dart';

class CustomFilterUsersSection extends StatefulWidget {
  const CustomFilterUsersSection({super.key});

  @override
  State<CustomFilterUsersSection> createState() =>
      _CustomFilterUsersSectionState();
}

class _CustomFilterUsersSectionState extends State<CustomFilterUsersSection> {
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
                  _buildSearchField(),
                  const SizedBox(width: 24),
                  _buildFilterDropdown(
                    hint: "الدور",
                    options: UsersFilterConstants.getRolesFilters(),
                    onChanged: (valEn) {},
                  ),
                  const SizedBox(width: 12),
                  _buildFilterDropdown(
                    hint: "الحالة",
                    options: UsersFilterConstants.getUsersStatusFilters(),
                    onChanged: (valEn) {},
                  ),
                  const SizedBox(width: 12),
                  _buildFilterDropdown(
                    hint: "الجنس",
                    options: UsersFilterConstants.getGenderFilters(),
                    onChanged: (valEn) {},
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
      width: 350,
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
