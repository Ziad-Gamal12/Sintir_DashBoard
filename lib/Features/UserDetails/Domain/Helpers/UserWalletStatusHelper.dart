import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';

class UserWalletStatusHelper {
  static String getUserWalletStatusArabic(String status) {
    if (status == BackendEndpoints.walletActive) {
      return "مفعل";
    } else if (status == BackendEndpoints.walletPending) {
      return "قيد المراجعة";
    } else if (status == BackendEndpoints.walletSuspended) {
      return "معلق";
    } else if (status == BackendEndpoints.walletClosed) {
      return "مغلق";
    } else {
      return "غير مفعل";
    }
  }

  static Color getUserWalletStatusColor(String status) {
    if (status == BackendEndpoints.walletActive) {
      return Colors.green;
    } else if (status == BackendEndpoints.walletPending) {
      return Colors.yellow;
    } else if (status == BackendEndpoints.walletSuspended) {
      return Colors.orange;
    } else if (status == BackendEndpoints.walletClosed) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }
}
