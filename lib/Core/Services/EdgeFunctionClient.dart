// ignore_for_file: file_names

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:sintir_dashboard/Core/Errors/Exceptions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Calls a Supabase Edge Function with the signed-in staff member's Firebase
/// ID token, the same way the app does.
class EdgeFunctionClient {
  Future<Map<String, dynamic>> invoke(
    String function,
    Map<String, dynamic> body,
  ) async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      throw CustomException(message: "انتهت الجلسة، سجّل الدخول مرة أخرى");
    }
    try {
      final response = await Supabase.instance.client.functions.invoke(
        function,
        headers: {'Authorization': 'Bearer $token'},
        body: body,
      );
      final data = response.data;
      if (data is Map && data['ok'] == true) {
        return Map<String, dynamic>.from(data);
      }
      throw CustomException(message: messageFor(codeOf(data)));
    } on FunctionException catch (e) {
      throw CustomException(message: messageFor(codeOf(e.details)));
    }
  }

  static String? codeOf(Object? payload) {
    Object? decoded = payload;
    if (decoded is String) {
      try {
        decoded = jsonDecode(decoded);
      } on FormatException {
        return null;
      }
    }
    final error = decoded is Map ? decoded['error'] : null;
    final code = error is Map ? error['code'] : null;
    return code is String ? code : null;
  }

  static String messageFor(String? code) {
    switch (code) {
      case 'forbidden':
        return "هذا الإجراء متاح للأدمن فقط";
      case 'feedback_not_found':
        return "التقييم غير موجود، ربما حُذف بالفعل";
      case 'unauthorized':
        return "انتهت الجلسة، سجّل الدخول مرة أخرى";
      default:
        return "تعذر تنفيذ العملية، حاول مرة أخرى";
    }
  }
}
