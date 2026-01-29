// ignore_for_file: file_names, depend_on_referenced_packages

import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStorePaginateResponse.dart';
import 'package:sintir_dashboard/Core/Entities/FireStoreEntities/FireStoreRequirmentsEntity.dart';
import 'package:sintir_dashboard/Core/Errors/Exceptioons.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/Services/FireBase/FirebaseAuth_Service.dart';
import 'package:sintir_dashboard/Core/Services/HiveService.dart';
import 'package:sintir_dashboard/Core/Utils/Backend_EndPoints.dart';
import 'package:sintir_dashboard/Features/Auth/Data/models/UserModel.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/UserEntity.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Repos/AuthRepo.dart';

class AuthRepoImpl implements AuthRepo {
  final FirebaseAuthService authService;
  final DataBaseService databaseservice;

  AuthRepoImpl({required this.authService, required this.databaseservice});

  Failure _toFailure(Object e, [StackTrace? s]) {
    if (e is CustomException) return ServerFailure(message: e.message);
    return ServerFailure(message: "حدث خطأ غير متوقع، يرجى المحاولة لاحقاً");
  }

  @override
  Future<Either<Failure, void>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      User user = await authService.signInWithEmailAndPassword(email, password);
      await user.reload();
      User? fresh = FirebaseAuth.instance.currentUser ?? user;

      if (fresh.emailVerified == false) {
        await fresh.sendEmailVerification();
        await authService.signout();
        return Left(
          ServerFailure(
            message:
                "يرجى تفعيل حسابك، تم إرسال رابط التفعيل إلى بريدك الإلكتروني",
          ),
        );
      } else {
        final updateDeviceIdResult = await updateDeviceId(uid: fresh.uid);
        if (updateDeviceIdResult.isLeft()) {
          await authService.signout();
          return updateDeviceIdResult;
        }
        final result = await fetchUserAndStoreLocally(uid: fresh.uid);
        if (result.isLeft()) {
          await authService.signout();
          return result;
        }
        return const Right(null);
      }
    } on FirebaseAuthException catch (e) {
      log(e.toString());
      await authService.signout();
      if (e.code == 'too-many-requests') {
        return Left(
          ServerFailure(message: "محاولات كثيرة جداً، تم حظر الدخول مؤقتاً"),
        );
      }
      return Left(
        ServerFailure(message: e.message ?? "حدث خطأ أثناء تسجيل الدخول"),
      );
    } on CustomException catch (e) {
      await authService.signout();
      return Left(ServerFailure(message: e.message));
    } catch (e, s) {
      log(e.toString(), stackTrace: s);
      await authService.signout();
      return Left(_toFailure(e, s));
    }
  }

  @override
  Future<Either<Failure, void>> signUpWithEmailAndPassword({
    required UserEntity userEntity,
    required String password,
  }) async {
    User? user;
    try {
      user = await authService.createUserWithEmailAndPassword(
        userEntity.email,
        password,
        '${userEntity.firstName} ${userEntity.lastName}',
      );

      userEntity.uid = user.uid;
      userEntity.deviceId = await getDeviceId();
      if (userEntity.teacherExtraDataEntity != null) {
        userEntity.teacherExtraDataEntity!.wallet.teacherId = user.uid;
      }

      final userModel = UserModel.fromEntity(userEntity);

      return await storeUserDataInFireStore(
        user: user,
        userjson: userModel.toMap(),
        uid: user.uid,
      );
    } on CustomException catch (e) {
      await _tryDeleteUser(user);
      return Left(ServerFailure(message: e.message));
    } catch (e, s) {
      await _tryDeleteUser(user);
      return Left(_toFailure(e, s));
    }
  }

  Future<void> _tryDeleteUser(User? user) async {
    if (user == null) return;
    try {
      await user.delete();
    } catch (e) {
      throw CustomException(message: "حدث خطاء ، يرجى المحاولة لاحقاً");
    }
  }

  Future<void> storeUserLocally(Map<String, dynamic> userJson) async {
    try {
      await Hive_Services.jsonSetter(
        key: BackendEndpoints.storeUserLocaly,
        value: userJson,
      );
    } catch (e) {
      log(e.toString());

      throw CustomException(
        message: "حدث خطأ أثناء حفظ بيانات المستخدم محلياً",
      );
    }
  }

  @override
  Future<Either<Failure, void>> fetchUserAndStoreLocally({
    required String uid,
  }) async {
    try {
      FireStoreResponse json = await databaseservice.getData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.usersCollectionName,
          docId: uid,
        ),
      );

      if (json.docData == null) {
        return Left(ServerFailure(message: "بيانات المستخدم غير موجودة"));
      }

      final Map<String, dynamic> userJson = json.docData!;
      final UserEntity userEntity = UserModel.fromJson(userJson).toEntity();

      switch (userEntity.status) {
        case BackendEndpoints.activeStatus:
          if (userEntity.role.toLowerCase() ==
                  BackendEndpoints.adminRole.toLowerCase() ||
              userEntity.role.toLowerCase() ==
                  BackendEndpoints.coursesManagerrRole.toLowerCase() ||
              userEntity.role.toLowerCase() ==
                  BackendEndpoints.usersManagerrRole.toLowerCase() ||
              userEntity.role.toLowerCase() ==
                  BackendEndpoints.supportRole.toLowerCase()) {
            await storeUserLocally(UserModel.fromJson(userJson).toMap());
            return const Right(null);
          } else {
            return Left(
              ServerFailure(
                message:
                    "عذراً، هذا الحساب لا يملك صلاحيات الوصول للوحة التحكم. يرجى مراجعة المسؤول.",
              ),
            );
          }
        case BackendEndpoints.blockedStatus:
          return Left(
            ServerFailure(message: "هذا الحساب محظور، يرجى التواصل مع الإدارة"),
          );

        case BackendEndpoints.pendingStatus:
          return Left(ServerFailure(message: "حسابك قيد المراجعة حالياً"));

        case BackendEndpoints.rejectedStatus:
          return Left(ServerFailure(message: "تم رفض طلب انضمام هذا الحساب"));

        case BackendEndpoints.inActiveStatus:
          return Left(ServerFailure(message: "هذا الحساب غير نشط"));

        default:
          return Left(
            ServerFailure(message: "حدث خطأ غير معروف في حالة الحساب"),
          );
      }
    } on CustomException catch (e) {
      log(e.toString());

      await authService.signout();
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      log(e.toString());

      await authService.signout();
      return Left(_toFailure(e));
    }
  }

  Future<Either<Failure, void>> storeUserDataInFireStore({
    required Map<String, dynamic> userjson,
    required User user,
    required String uid,
    bool signOut = true,
    bool checkVerified = true,
  }) async {
    try {
      await databaseservice.setData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.usersCollectionName,
          docId: uid,
        ),
        data: userjson,
      );

      if (checkVerified) {
        try {
          await user.sendEmailVerification();
        } catch (e) {
          return Left(
            ServerFailure(
              message: "فشل إرسال بريد التفعيل، يرجى المحاولة من الإعدادات",
            ),
          );
        }
      }

      if (signOut) await authService.signout();

      return const Right(null);
    } catch (e, s) {
      return Left(_toFailure(e, s));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(
    String? newPassword, {
    required UserEntity userEntity,
    required String currentPassword,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        return Left(ServerFailure(message: "مستخدم غير مسجل"));
      }

      Map<String, dynamic> userJson = UserModel.fromEntity(userEntity).toMap();

      bool isValid = await authService.checkAccountPassword(
        password: currentPassword,
      );
      if (!isValid) {
        return Left(ServerFailure(message: "كلمة المرور الحالية غير صحيحة"));
      }

      if (newPassword != null && newPassword.isNotEmpty) {
        await authService.changePassword(password: newPassword);
      }

      if (userEntity.email != user.email) {
        await authService.changeEmail(email: userEntity.email);
      }

      final result = await storeUserDataInFireStore(
        user: user,
        userjson: userJson,
        uid: user.uid,
        signOut: false,
        checkVerified: false,
      );

      if (result.isLeft()) return result;

      await storeUserLocally(userJson);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: "فشل تحديث البيانات، حاول مرة أخرى"));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    try {
      await authService.resetPassword(email: email);
      return const Right(null);
    } catch (e, s) {
      return Left(_toFailure(e, s));
    }
  }

  @override
  Future<String> getDeviceId() async {
    try {
      var deviceInfo = DeviceInfoPlugin();

      if (kIsWeb) {
        var webInfo = await deviceInfo.webBrowserInfo;
        return "${webInfo.vendor}${webInfo.userAgent}${webInfo.hardwareConcurrency}";
      }

      if (Platform.isIOS) {
        var iosDeviceInfo = await deviceInfo.iosInfo;
        return iosDeviceInfo.identifierForVendor ?? '';
      }

      if (Platform.isAndroid) {
        var androidDeviceInfo = await deviceInfo.androidInfo;
        return androidDeviceInfo.id; // Unique ID for the app/device pair
      }

      // 3. Handle Desktop Platforms
      if (Platform.isWindows) {
        var windowsDeviceInfo = await deviceInfo.windowsInfo;
        return windowsDeviceInfo.deviceId;
      }

      if (Platform.isLinux) {
        var linuxDeviceInfo = await deviceInfo.linuxInfo;
        return linuxDeviceInfo.machineId ?? '';
      }

      if (Platform.isMacOS) {
        var macosDeviceInfo = await deviceInfo.macOsInfo;
        return macosDeviceInfo.systemGUID ?? '';
      }

      return 'unknown_device';
    } catch (e) {
      return '';
    }
  }

  Future<Either<Failure, void>> updateDeviceId({required String uid}) async {
    try {
      final deviceId = await getDeviceId();
      await databaseservice.updateData(
        requirements: FireStoreRequirmentsEntity(
          collection: BackendEndpoints.usersCollectionName,
          docId: uid,
        ),
        data: deviceId,
        field: 'deviceId',
      );

      return const Right(null);
    } catch (e, s) {
      return Left(_toFailure(e, s));
    }
  }
}
