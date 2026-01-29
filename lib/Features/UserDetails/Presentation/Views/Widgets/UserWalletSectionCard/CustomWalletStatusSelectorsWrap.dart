import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Features/UserDetails/Domain/Entities/WalletStatusSelectorEntity.dart';
import 'package:sintir_dashboard/Features/UserDetails/Presentation/Views/Widgets/UserWalletSectionCard/CustomWalletStatusSelectorItem.dart';

class CustomWalletStatusSelectorsWrap extends StatefulWidget {
  CustomWalletStatusSelectorsWrap({
    super.key,
    this.initialStatus,
    required this.onStatusChanged,
  });
  String? initialStatus;
  final ValueChanged<String> onStatusChanged;
  @override
  State<CustomWalletStatusSelectorsWrap> createState() =>
      _CustomWalletStatusSelectorsWrapState();
}

class _CustomWalletStatusSelectorsWrapState
    extends State<CustomWalletStatusSelectorsWrap> {
  final List<WalletStatusSelectorEntity> walletStatuses =
      WalletStatusSelectorEntity.getWalletStatuses();
  int selectedWalletStatusIndex = -1;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.initialStatus != null && widget.initialStatus!.isNotEmpty) {
        selectedWalletStatusIndex = walletStatuses.indexWhere(
          (element) => element.statusValue == widget.initialStatus,
        );
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: walletStatuses
          .asMap()
          .entries
          .map(
            (walletStatus) => CustomWalletStatusSelectorItem(
              item: walletStatus.value,
              onTap: () {
                setState(() {
                  selectedWalletStatusIndex = walletStatus.key;
                });
                widget.onStatusChanged(walletStatus.value.statusValue);
              },
              isSelected: selectedWalletStatusIndex == walletStatus.key,
            ),
          )
          .toList(),
    );
  }
}
