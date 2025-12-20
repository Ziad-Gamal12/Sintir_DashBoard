import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/imageAssets.dart';
import 'package:sintir_dashboard/Core/Utils/textStyles.dart';
import 'package:svg_flutter/svg_flutter.dart';

class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget({super.key, required this.errormessage});
  final String errormessage;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SvgPicture.asset(
          Assets.assetsImagesSVGImagesErorr,
          height: 70,
          width: 70,
          fit: BoxFit.fill,
        ),
        const SizedBox(height: 10),
        Text(
          errormessage,
          textAlign: TextAlign.center,
          style: AppTextStyles(context).semiBold16,
        ),
      ],
    );
  }
}
