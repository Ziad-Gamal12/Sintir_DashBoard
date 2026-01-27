// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class BirthDatePickerField extends StatefulWidget {
  const BirthDatePickerField({
    super.key,
    required this.onDateChanged,
    required this.initialDate,
  });
  final ValueChanged<DateTime?> onDateChanged;
  final String initialDate;
  @override
  State<BirthDatePickerField> createState() => _BirthDatePickerFieldState();
}

class _BirthDatePickerFieldState extends State<BirthDatePickerField> {
  DateTime? pickedDate;

  void showdatepicker() {
    showDatePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: DateTime(2025),
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

    return InkWell(
      onTap: showdatepicker,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xffF9FAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : const Color(0xffF9FAFA),
            width: 2,
          ),
        ),
        child: ListTile(
          title: Text(
            getBirthDate(),
            style: AppTextStyles(context).bold14.copyWith(
              color: pickedDate == null
                  ? (isDark ? Colors.white54 : const Color(0xffAEAEB2))
                  : (isDark ? Colors.white70 : Colors.grey.shade700),
            ),
          ),
          leading: Icon(
            Icons.date_range_outlined,
            color: isDark ? Colors.white70 : const Color(0xFF6C6C70),
          ),
        ),
      ),
    );
  }

  String getBirthDate() {
    if (pickedDate != null && widget.initialDate.isEmpty) {
      return "${pickedDate!.day}/${pickedDate!.month}/${pickedDate!.year}";
    } else if (pickedDate == null && widget.initialDate.isNotEmpty) {
      return widget.initialDate;
    } else {
      return "تاريخ الميلاد";
    }
  }
}
