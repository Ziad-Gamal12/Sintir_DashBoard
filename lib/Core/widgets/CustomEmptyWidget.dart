import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/imageAssets.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';

class CustomEmptyWidget extends StatelessWidget {
  CustomEmptyWidget({super.key, this.text});
  String? text;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Image.asset(Assets.assetsIconsEmptyBox),
          const SizedBox(height: 10),
          Text(
            text ?? "فارغ جرب مره تانى فى وقت تانى",
            style: AppTextStyles(context).semiBold16,
          ),
        ],
      ),
    );
  }
}
