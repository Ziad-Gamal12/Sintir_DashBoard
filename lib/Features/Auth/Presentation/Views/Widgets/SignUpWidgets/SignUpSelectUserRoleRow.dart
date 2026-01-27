// ignore_for_file: must_be_immutable, file_names

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/SignUpUserRoleEntity.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/SignUpWidgets/SignUpSelectUserRoleRowItem.dart';

class SignUpSelectUserRoleRow extends StatefulWidget {
  const SignUpSelectUserRoleRow({
    super.key,
    this.onRoleSelected,
    this.initialRole,
  });
  final String? initialRole;
  final void Function(String roleKey)? onRoleSelected;

  @override
  State<SignUpSelectUserRoleRow> createState() =>
      _SignUpSelectUserRoleRowState();
}

class _SignUpSelectUserRoleRowState extends State<SignUpSelectUserRoleRow> {
  final List<SignUpUserRoleEntity> roles = SignUpUserRoleEntity.getItems();
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    // Senior Note: Calculate index immediately to avoid UI flicker
    selectedIndex = roles.indexWhere((e) => e.value == widget.initialRole);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(), // Better feel on mobile
      child: Row(
        children: roles.asMap().entries.map((entry) {
          final index = entry.key;
          final entity = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () {
                if (selectedIndex == index)
                  return; // Performance: Don't rebuild if same
                setState(() => selectedIndex = index);
                widget.onRoleSelected?.call(entity.value);
              },
              child:
                  SignUpSelectUserRoleRowItem(
                        entity: entity,
                        isSelected: selectedIndex == index,
                      )
                      .animate(target: selectedIndex == index ? 1 : 0)
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.0, 1.0),
                      ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
