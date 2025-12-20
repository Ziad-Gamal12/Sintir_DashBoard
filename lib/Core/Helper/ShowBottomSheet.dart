import 'package:flutter/material.dart';

showCustomBottomSheet({required Widget child, required BuildContext context}) {
  final theme = Theme.of(context);

  showBottomSheet(
    context: context,
    backgroundColor: theme.cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
    ),
    builder: (context) => child,
  );
}

showCustomModalBottomSheet({
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
      side: BorderSide(color: theme.dividerColor),
    ),
    builder: (context) => child,
  );
}
