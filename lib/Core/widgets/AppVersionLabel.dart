import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class AppVersionLabel extends StatelessWidget {
  final String version;

  const AppVersionLabel({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    return Text(
      "الإصدار $version",
      style: AppTextStyles(context).regular10.copyWith(color: Colors.grey),
    );
  }
}
