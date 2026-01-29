import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';

class WalletStatusSelectorEntity {
  final String statusLabel;
  final String statusValue;
  final Color color;
  final IconData icon;

  WalletStatusSelectorEntity({
    required this.statusLabel,
    required this.statusValue,
    required this.color,
    required this.icon,
  });

  static List<WalletStatusSelectorEntity> getWalletStatuses() => [
    WalletStatusSelectorEntity(
      statusLabel: "مفعلة",
      statusValue: BackendEndpoints.walletActive,
      color: Colors.green,
      icon: Icons.check,
    ),
    WalletStatusSelectorEntity(
      statusLabel: "قيد المراجعة",
      statusValue: BackendEndpoints.walletPending,
      color: Colors.yellow,
      icon: Icons.pending_actions,
    ),
    WalletStatusSelectorEntity(
      statusLabel: "معلقة",
      statusValue: BackendEndpoints.walletSuspended,
      color: Colors.orange,
      icon: Icons.pause,
    ),
    WalletStatusSelectorEntity(
      statusLabel: "مغلقة",
      statusValue: BackendEndpoints.walletClosed,
      color: Colors.red,
      icon: Icons.close,
    ),
  ];
}
