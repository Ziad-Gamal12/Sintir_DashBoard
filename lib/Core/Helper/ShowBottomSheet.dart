import 'package:flutter/material.dart';

void showCustomBottomSheet({
  required Widget child,
  required BuildContext context,
}) {
  final theme = Theme.of(context);

  showBottomSheet(
    context: context,
    backgroundColor: theme.cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    builder: (context) => child,
  );
}

void showCustomModalBottomSheet({
  required Widget child,
  required BuildContext context,
}) {
  final theme = Theme.of(context);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    backgroundColor: theme.cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
    ),
    builder: (context) => child,
  );
}
