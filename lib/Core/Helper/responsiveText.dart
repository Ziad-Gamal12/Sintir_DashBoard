// ignore_for_file: file_names

import 'package:flutter/material.dart';

getresposiveTet({required BuildContext context, required double basesize}) {
  double scaleFactor = getScaleFactor(context);
  double responsiveFontSize = basesize * scaleFactor;
  double lowerLimit = responsiveFontSize * .8;
  double upperLimit = responsiveFontSize * 1.2;
  return responsiveFontSize.clamp(lowerLimit, upperLimit);
}

double getScaleFactor(BuildContext context) {
  double width = MediaQuery.sizeOf(context).width;
  if (width < 600) {
    return width / 400;
  } else if (width < 900) {
    return width / 600;
  } else {
    return width / 1000;
  }
}
