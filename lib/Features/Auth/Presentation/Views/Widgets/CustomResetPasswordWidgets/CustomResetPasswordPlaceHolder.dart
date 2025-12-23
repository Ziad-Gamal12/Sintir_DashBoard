import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sintir_dashboard/Core/Helper/ResponsiveLayout%20.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/reset_password_feature_entity.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/AuthFeatureTile.dart';
import 'package:sintir_dashboard/Features/Auth/Presentation/Views/Widgets/CustomResetPasswordWidgets/CustomResetFeatureHeader.dart';
import 'package:sintir_dashboard/constant.dart';

class ResetPasswordWelcomePlaceholder extends StatelessWidget {
  const ResetPasswordWelcomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final features = ResetPasswordFeatureEntity.getItems();

    return ResponsiveLayout(
      mobile: const SizedBox.shrink(),
      tablet: const SizedBox.shrink(),
      desktop: Container(
        height: double.infinity,
        width: MediaQuery.sizeOf(context).width / 2,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [KMainColor, const Color(0xFF0F1520)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomResetFeatureHeader()
                .animate()
                .fadeIn(duration: 600.ms)
                .slideX(begin: -0.2),
            const SizedBox(height: 40),
            ...List.generate(features.length, (index) {
              final feature = features[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child:
                    AuthFeatureTile(
                          icon: feature.icon,
                          iconColor: feature.color,
                          title: feature.title,
                          subtitle: feature.subtitle,
                        )
                        .animate()
                        .fadeIn(delay: (200 * index).ms, duration: 600.ms)
                        .moveY(
                          begin: 30,
                          end: 0,
                          delay: (200 * index).ms,
                          curve: Curves.easeOutQuad,
                        ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
