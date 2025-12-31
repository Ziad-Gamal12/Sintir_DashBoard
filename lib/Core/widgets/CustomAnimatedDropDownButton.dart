import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomTextFields/CustomSearchTextField.dart';

class CustomAnimatedDropDownButton extends StatefulWidget {
  const CustomAnimatedDropDownButton({
    super.key,
    required this.items,
    required this.onChanged,
    this.hintText,
  });

  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? hintText;

  @override
  State<CustomAnimatedDropDownButton> createState() =>
      _CustomAnimatedDropDownButtonState();
}

class _CustomAnimatedDropDownButtonState
    extends State<CustomAnimatedDropDownButton> {
  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Pulling colors from your AppTheme for perfect consistency
    final Color primaryColor = theme.primaryColor;
    final Color borderColor = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.grey.shade300;
    final Color dropdownBg = theme.colorScheme.surface;

    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: Text(
          widget.hintText ?? "اختر...",
          style: AppTextStyles(
            context,
          ).regular14.copyWith(color: isDark ? Colors.white38 : Colors.black38),
        ),
        items: widget.items
            .map(
              (String item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: AppTextStyles(context).regular14.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            )
            .toList(),
        value: selectedValue,
        onChanged: (value) {
          setState(() => selectedValue = value);
          widget.onChanged(value);
        },
        buttonStyleData: ButtonStyleData(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              12,
            ), // Matches your inputDecorationTheme
            border: Border.all(color: borderColor),
            color: Colors.transparent,
          ),
        ),
        iconStyleData: IconStyleData(
          icon: const Icon(Icons.arrow_drop_down),
          iconSize: 24,
          iconEnabledColor: isDark ? Colors.white60 : Colors.black54,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 300,
          width: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: dropdownBg,
            border: Border.all(color: borderColor),
          ),
          elevation: 0,
          offset: const Offset(0, -4),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: WidgetStateProperty.all(4),
            thumbColor: WidgetStateProperty.all(primaryColor.withOpacity(0.3)),
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          // Subtle hover effect
          selectedMenuItemBuilder: (context, child) {
            return Container(
              color: primaryColor.withOpacity(0.08),
              child: child,
            );
          },
        ),
        dropdownSearchData: DropdownSearchData(
          searchController: textEditingController,
          searchInnerWidgetHeight: 60,
          searchInnerWidget: Container(
            height: 60,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: CustomSearchTextField(controller: textEditingController),
          ),
          searchMatchFn: (item, searchValue) {
            return item.value.toString().toLowerCase().contains(
              searchValue.toLowerCase(),
            );
          },
        ),
        onMenuStateChange: (isOpen) {
          if (!isOpen) {
            textEditingController.clear();
          }
        },
      ),
    );
  }
}
