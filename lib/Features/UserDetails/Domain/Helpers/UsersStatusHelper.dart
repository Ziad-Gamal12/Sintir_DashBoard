import 'package:flutter/material.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';

class UsersStatusHelper {
  static String getUserStatusArabic(String status) {
    if (status == BackendEndpoints.activeStatus) {
      return "مفعل";
    } else if (status == BackendEndpoints.pending) {
      return "قيد المراجعة";
    } else if (status == BackendEndpoints.blockedStatus) {
      return "محظور";
    } else if (status == BackendEndpoints.courseDeletedByAdminState) {
      return "محذوف من قبل المدير";
    } else if (status == BackendEndpoints.courseDeletedByTeacherState) {
      return "محذوف من قبل المعلم";
    } else if (status == BackendEndpoints.rejectedStatus) {
      return "غير مفعل";
    } else {
      return "غير مفعل";
    }
  }

  static Color getUserStatusColor(String status) {
    if (status == BackendEndpoints.activeStatus) {
      return Colors.green;
    } else if (status == BackendEndpoints.pending) {
      return Colors.yellow;
    } else if (status == BackendEndpoints.blockedStatus) {
      return Colors.red;
    } else if (status == BackendEndpoints.courseDeletedByAdminState) {
      return Colors.red;
    } else if (status == BackendEndpoints.courseDeletedByTeacherState) {
      return Colors.red;
    } else if (status == BackendEndpoints.rejectedStatus) {
      return Colors.red;
    } else {
      return Colors.red;
    }
  }
}
