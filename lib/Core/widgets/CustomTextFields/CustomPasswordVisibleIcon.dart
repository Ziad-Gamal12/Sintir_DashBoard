// ignore_for_file: file_names

import 'package:flutter/material.dart';

class Custompasswordvisibleicon extends StatefulWidget {
  const Custompasswordvisibleicon({super.key, required this.visibilityChanged});
  final ValueChanged<bool> visibilityChanged;

  @override
  State<Custompasswordvisibleicon> createState() =>
      _CustompasswordvisibleiconState();
}

class _CustompasswordvisibleiconState extends State<Custompasswordvisibleicon> {
  bool isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: IconButton(
        icon: Icon(
          isPasswordVisible == false ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey,
        ),
        onPressed: () {
          setState(() {
            isPasswordVisible = !isPasswordVisible;
          });
          widget.visibilityChanged(isPasswordVisible);
        },
      ),
    );
  }
}
