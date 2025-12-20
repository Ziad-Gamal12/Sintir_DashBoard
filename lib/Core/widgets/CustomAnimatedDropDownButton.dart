import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CustomAnimatedDropDownButton extends StatelessWidget {
  const CustomAnimatedDropDownButton({
    super.key,
    required this.items,
    required this.onChanged,
    this.hintText,
  });

  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? hintText;

  Future<List<String>> _getFakeRequestData(String query) async {
    return await Future.delayed(const Duration(milliseconds: 300), () {
      return items.where((e) {
        return e.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final Color surfaceColor = isDarkMode
        ? const Color(0xFF1E1E1E)
        : Colors.white;
    final Color borderColor = isDarkMode
        ? Colors.white10
        : const Color(0xFFE4E6E8);
    final Color searchColor = isDarkMode
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFF8F9FA);

    return CustomDropdown<String>.searchRequest(
      futureRequest: _getFakeRequestData,
      hintText: hintText ?? "اختر من القائمة",
      headerBuilder: (context, selectedItem, enabled) => Text(
        selectedItem,
        style: AppTextStyles(
          context,
        ).semiBold14.copyWith(color: theme.textTheme.bodyLarge?.color),
      ),
      hintBuilder: (context, hint, enabled) => Text(
        hint,
        style: AppTextStyles(
          context,
        ).regular14.copyWith(color: theme.hintColor.withOpacity(0.5)),
      ),
      decoration: CustomDropdownDecoration(
        closedShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        expandedShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        searchFieldDecoration: SearchFieldDecoration(
          fillColor: searchColor,
          prefixIcon: Icon(Icons.search, color: theme.hintColor, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor),
          ),
          textStyle: AppTextStyles(context).regular14,
          hintStyle: AppTextStyles(
            context,
          ).regular14.copyWith(color: theme.hintColor),
        ),
        expandedFillColor: surfaceColor,
        closedFillColor: surfaceColor,
        closedBorder: Border.all(color: borderColor, width: 1.2),
        expandedBorder: Border.all(
          color: theme.primaryColor.withOpacity(0.5),
          width: 1.2,
        ),
        closedBorderRadius: BorderRadius.circular(14),
        expandedBorderRadius: BorderRadius.circular(14),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}
