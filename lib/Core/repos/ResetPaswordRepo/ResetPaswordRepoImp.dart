// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:sintir_dashboard/Core/repos/ResetPaswordRepo/ResetPaswordRepo.dart';

class ResetPaswordRepoImp implements ResetPaswordRepo {
  final FirebaseAuth authService;
  ResetPaswordRepoImp({required this.authService});
  @override
  Future<void> resetPassword({required String email}) async {
    await authService.sendPasswordResetEmail(email: email);
  }
}
