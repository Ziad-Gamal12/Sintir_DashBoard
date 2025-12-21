import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/imageAssets.dart';
import 'package:svg_flutter/svg_flutter.dart';

class SplashAppLogo extends StatelessWidget {
  const SplashAppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;

    double logoSize = (screenWidth / 8).clamp(80.0, 200.0);
    return SizedBox(
      width: logoSize,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent.withOpacity(.1),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: SvgPicture.asset(
            Assets.assetsIconsSVGIconsAppLogo,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
