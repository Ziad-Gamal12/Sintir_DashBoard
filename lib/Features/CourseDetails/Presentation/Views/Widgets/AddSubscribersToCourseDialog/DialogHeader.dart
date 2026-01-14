import 'package:flutter/material.dart';

class DialogHeader extends StatelessWidget {
  const DialogHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "إضافة مستخدمين",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          "يمكنك اضافة مستخدمين للدورة",
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}
