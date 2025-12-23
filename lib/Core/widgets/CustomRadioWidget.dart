import 'package:flutter/material.dart';
import 'package:sintir_dashboard/constant.dart';

class CustomRadioWidget extends StatelessWidget {
  const CustomRadioWidget({
    super.key,
    required this.value,
    required this.onchange,
    required this.groupValue,
  });

  final String value;
  final String groupValue;
  final ValueChanged<String?> onchange;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(unselectedWidgetColor: Colors.white.withOpacity(0.3)),
      child: Radio<String>(
        activeColor: KMainColor,
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return KMainColor;
          }
          return Colors.white.withOpacity(0.4);
        }),
        overlayColor: WidgetStateProperty.all(KMainColor.withOpacity(0.1)),
        value: value,
        groupValue: groupValue,
        onChanged: onchange,
        visualDensity: const VisualDensity(
          horizontal: VisualDensity.minimumDensity,
          vertical: VisualDensity.minimumDensity,
        ),
      ),
    );
  }
}
