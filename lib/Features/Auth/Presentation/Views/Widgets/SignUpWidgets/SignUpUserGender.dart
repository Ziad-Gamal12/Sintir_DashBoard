import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:sintir_dashboard/Core/widgets/CustomRadioWidget.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/constant.dart';

class SignUpUserGender extends StatefulWidget {
  const SignUpUserGender({super.key, required this.userEntity});
  final UserEntity userEntity;

  @override
  State<SignUpUserGender> createState() => _SignUpUserGenderState();
}

class _SignUpUserGenderState extends State<SignUpUserGender> {
  late String groupValue;

  @override
  void initState() {
    super.initState();
    groupValue = widget.userEntity.gender;
  }

  void _updateGender(String? val) {
    if (val != null) {
      setState(() {
        groupValue = val;
      });
      widget.userEntity.gender = val;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildGenderOption(
              label: "ذكر",
              value: "Male",
              icon: FontAwesomeIcons.mars,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildGenderOption(
              label: "أنثى",
              value: "Female",
              icon: FontAwesomeIcons.venus,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final bool isSelected = groupValue == value;
    return InkWell(
      onTap: () => _updateGender(value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? KMainColor.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? KMainColor : Colors.white.withOpacity(0.1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            CustomRadioWidget(
              value: value,
              groupValue: groupValue,
              onchange: _updateGender,
            ),
            const SizedBox(width: 8),
            Icon(
              icon,
              size: 14,
              color: isSelected ? KMainColor : Colors.white.withOpacity(0.4),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles(context).regular14.copyWith(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
