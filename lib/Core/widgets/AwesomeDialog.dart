// ignore_for_file: non_constant_identifier_names, file_names

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

AwesomeDialog errordialog(
  BuildContext context,
  String? error, {
  void Function()? btnOkOnPress,
}) {
  return AwesomeDialog(
    context: context,
    dialogType: DialogType.error,
    animType: AnimType.bottomSlide,
    title: "خطأ",
    desc: error,
    btnOkText: "حسناً",
    btnOkOnPress: btnOkOnPress,
    btnOkColor: Colors.red,
  );
}

AwesomeDialog successdialog({
  required BuildContext context,
  required String? SuccessMessage,
  required void Function()? btnOkOnPress,
}) {
  return AwesomeDialog(
    context: context,
    dialogType: DialogType.success,
    animType: AnimType.bottomSlide,
    title: "تم بنجاح",
    desc: SuccessMessage,
    btnOkText: "تم",
    btnOkOnPress: btnOkOnPress,
    btnOkColor: Colors.green,
  );
}

AwesomeDialog warningdialog(
  BuildContext context,
  String? WarningMessage,
  void Function()? btnOkOnPress,
) {
  return AwesomeDialog(
    context: context,
    dialogType: DialogType.warning,
    animType: AnimType.bottomSlide,
    title: "تحذير",
    desc: WarningMessage,
    btnOkText: "موافق",
    btnOkOnPress: btnOkOnPress,
    btnOkColor: Colors.yellow.shade800,
  );
}

AwesomeDialog infodialog({
  required BuildContext context,
  String? InfoMessage,
  String? btnOkText,
  void Function()? btnOkOnPress,
  void Function()? btnCancelOnPress,
  String? btnCancelText,
}) {
  return AwesomeDialog(
    context: context,
    dialogType: DialogType.info,
    animType: AnimType.bottomSlide,
    title: "تنبيه",
    desc: InfoMessage,
    btnOkOnPress: btnOkOnPress,
    btnOkText: btnOkText ?? "تأكيد",
    btnCancelText: btnCancelText ?? "إلغاء",
    btnCancelOnPress: btnCancelOnPress,
    btnCancelColor: Colors.grey,
    btnOkColor: Colors.blue,
  );
}
