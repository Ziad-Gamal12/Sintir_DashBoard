// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class DatePickerField extends StatefulWidget {
  const DatePickerField({
    super.key,
    required this.onDateChanged,
    required this.initialDate,
  });
  final ValueChanged<DateTime?> onDateChanged;
  final String initialDate;
  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  DateTime? pickedDate;

  void showdatepicker() {
    showDatePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendar,
      builder: (context, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF4E7EFF),
                    onPrimary: Colors.white,
                    onSurface: Colors.white70,
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF4E7EFF),
                    onPrimary: Colors.white,
                    onSurface: Colors.black87,
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF4E7EFF),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: child!,
          ),
        );
      },
    ).then((value) {
      if (!mounted) return;
      widget.onDateChanged(value);
      setState(() {
        pickedDate = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color borderColor = isDark ? Colors.white10 : const Color(0xFFE4E6E8);
    final Color fillBg = isDark
        ? Colors.white.withOpacity(0.02)
        : const Color(0xFFF8F9FA);

    return InkWell(
      onTap: showdatepicker,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: fillBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: ListTile(
          title: Text(
            getBirthDate(),
            style: AppTextStyles(context).regular14.copyWith(
              color: pickedDate == null && widget.initialDate.isEmpty
                  ? (isDark ? Colors.white54 : const Color(0xffAEAEB2))
                  : (isDark ? Colors.white : Colors.grey.shade700),
            ),
          ),
          leading: Icon(
            Icons.calendar_month_outlined,
            size: 20,
            color: theme.primaryColor.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  String getBirthDate() {
    if (pickedDate != null) {
      return "${pickedDate!.day}/${pickedDate!.month}/${pickedDate!.year}";
    } else if (pickedDate == null && widget.initialDate.isNotEmpty) {
      return widget.initialDate;
    } else {
      return "أختر التاريخ";
    }
  }
}
