// ignore_for_file: file_names, camel_case_types, depend_on_referenced_packages

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:sintir_dashboard/Core/errors/Exceptioons.dart';

class FirebaseAuthService {
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<User> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(name);
      await auth.currentUser!.reload();
      return auth.currentUser!;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          throw CustomException(message: "كلمة المرور ضعيفة جداً");
        case 'email-already-in-use':
        case 'account-exists-with-different-credential':
          throw CustomException(message: "هذا البريد الإلكتروني مستخدم بالفعل");
        case "network-request-failed":
          throw CustomException(message: "لا يوجد اتصال بالإنترنت");
        case "operation-not-allowed":
          throw CustomException(message: "هذه العملية غير مسموح بها حالياً");
        case "too-many-requests":
          throw CustomException(
            message: "محاولات كثيرة جداً، يرجى المحاولة لاحقاً",
          );
        case "internal-error":
          throw CustomException(message: "حدث خطأ داخلي في النظام");
        default:
          throw CustomException(
            message: "حدث خطأ أثناء إنشاء الحساب، حاول مرة أخرى",
          );
      }
    } catch (e) {
      throw CustomException(message: "حدث خطأ غير متوقع");
    }
  }

  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw CustomException(message: "هذا الحساب غير موجود");
        case 'wrong-password':
        case "invalid-credential":
          throw CustomException(
            message: "البريد الإلكتروني أو كلمة المرور غير صحيحة",
          );
        case "too-many-requests":
          throw CustomException(
            message: "تم حظر المحاولات مؤقتاً لكثرة الطلبات",
          );
        case 'network-request-failed':
          throw CustomException(message: "يرجى التحقق من اتصالك بالإنترنت");
        case "internal-error":
          throw CustomException(message: "خطأ في الخادم، حاول لاحقاً");
        case "user-disabled":
          throw CustomException(message: "تم تعطيل هذا الحساب من قبل الإدارة");
        default:
          throw CustomException(message: "فشل تسجيل الدخول، حاول مرة أخرى");
      }
    } catch (e) {
      throw CustomException(message: "حدث خطأ غير متوقع");
    }
  }

  Future<void> deleteUSerCurrentUser() async {
    try {
      await auth.currentUser?.delete();
    } catch (e) {
      throw CustomException(
        message: "فشل حذف الحساب، قد تحتاج لتسجيل الدخول مرة أخرى",
      );
    }
  }

  Future<void> signout() async {
    await auth.signOut();
  }

  Future<bool> isLoggedIn() async {
    return auth.currentUser != null;
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw CustomException(message: "البريد الإلكتروني غير مسجل لدينا");
        case "invalid-email":
          throw CustomException(message: "صيغة البريد الإلكتروني غير صحيحة");
        case "network-request-failed":
          throw CustomException(message: "لا يوجد اتصال بالإنترنت");
        default:
          throw CustomException(message: "تعذر إرسال بريد استعادة كلمة المرور");
      }
    }
  }

  Future<bool> checkAccountPassword({required String password}) async {
    try {
      final user = auth.currentUser;
      if (user == null) return false;

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "wrong-password":
        case "invalid-credential":
          throw CustomException(message: "كلمة المرور الحالية غير صحيحة");
        case "too-many-requests":
          throw CustomException(message: "محاولات كثيرة، حاول لاحقاً");
        default:
          throw CustomException(message: "فشل التحقق من الهوية");
      }
    }
  }

  Future<void> changePassword({required String password}) async {
    try {
      final user = auth.currentUser;
      if (user == null) return;
      await user.updatePassword(password);
    } on FirebaseAuthException catch (e) {
      if (e.code == "requires-recent-login") {
        throw CustomException(
          message: "يرجى تسجيل الدخول مجدداً لتغيير كلمة المرور",
        );
      }
      throw CustomException(message: "فشل تغيير كلمة المرور");
    }
  }

  Future<void> changeEmail({required String email}) async {
    try {
      final user = auth.currentUser;
      if (user == null) return;
      await user.verifyBeforeUpdateEmail(email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-email":
          throw CustomException(message: "البريد الإلكتروني الجديد غير صالح");
        case "email-already-in-use":
          throw CustomException(
            message: "البريد الإلكتروني الجديد مستخدم بالفعل",
          );
        default:
          throw CustomException(message: "فشل تحديث البريد الإلكتروني");
      }
    }
  }
}
