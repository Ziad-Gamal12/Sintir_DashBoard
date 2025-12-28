import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class SubscribersCount extends StatelessWidget {
  const SubscribersCount({super.key, required this.count});
  final int count;
  @override
  Widget build(BuildContext context) {
    return Text(count.toString(), style: AppTextStyles(context).semiBold12);
  }
}
