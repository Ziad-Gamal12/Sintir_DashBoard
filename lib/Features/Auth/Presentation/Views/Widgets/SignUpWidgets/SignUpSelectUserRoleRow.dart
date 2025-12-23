import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/SignUpUserRoleEntity.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignUpWidgets/SignUpSelectUserRoleRowItem.dart';

class SignUpSelectUserRoleRow extends StatefulWidget {
  const SignUpSelectUserRoleRow({super.key, this.onRoleSelected});

  final void Function(String roleKey)? onRoleSelected;

  @override
  State<SignUpSelectUserRoleRow> createState() =>
      _SignUpSelectUserRoleRowState();
}

class _SignUpSelectUserRoleRowState extends State<SignUpSelectUserRoleRow> {
  final List<SignUpUserRoleEntity> roles = SignUpUserRoleEntity.getItems();
  int selectedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: roles.asMap().entries.map((entry) {
        int index = entry.key;
        SignUpUserRoleEntity entity = entry.value;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
                if (widget.onRoleSelected != null) {
                  widget.onRoleSelected!(entity.value);
                }
              },
              child:
                  SignUpSelectUserRoleRowItem(
                        entity: entity,
                        isSelected: selectedIndex == index,
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: (100 * index).ms)
                      .slideX(begin: -0.1, end: 0, curve: Curves.easeOutQuad),
            ),
          ),
        );
      }).toList(),
    );
  }
}
