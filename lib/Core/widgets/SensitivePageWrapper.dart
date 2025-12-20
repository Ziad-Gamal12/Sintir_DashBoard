import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:secure_content/secure_content.dart';

class SensitivePageWrapper extends StatelessWidget {
  final Widget child;
  const SensitivePageWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return SecureWidget(
      isSecure: true,
      protectInAppSwitcherMenu: true,
      overlayWidgetBuilder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: const SizedBox.expand(),
      ),
      appSwitcherMenuColor: Colors.black,
      builder: (ctx, onInit, onDispose) {
        onInit();
        return child;
      },
    );
  }
}
