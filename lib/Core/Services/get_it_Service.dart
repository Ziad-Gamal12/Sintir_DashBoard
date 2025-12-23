// ignore_for_file: file_names, non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/Services/FireBase/FirebaseAuth_Service.dart';
import 'package:sintir_dashboard/Core/Services/FireBase/Firebase_FirestoreService.dart';
import 'package:sintir_dashboard/Core/Services/FireBase/firebaseStorageService.dart';
import 'package:sintir_dashboard/Core/Services/PickerAssetsServiceMobile.dart';
import 'package:sintir_dashboard/Core/Services/StorageService.dart';
import 'package:sintir_dashboard/Core/Services/picker_assets_interface.dart';
import 'package:sintir_dashboard/Core/repos/ResetPaswordRepo/ResetPaswordRepo.dart';
import 'package:sintir_dashboard/Core/repos/ResetPaswordRepo/ResetPaswordRepoImp.dart';
import 'package:sintir_dashboard/Features/Auth/Data/repos/AuthRepoImpl.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Repos/AuthRepo.dart';

final getIt = GetIt.instance;

void setup_Getit() {
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService());
  getIt.registerSingleton<PickerAssetsInterface>(PickerAssetsService());
  getIt.registerSingleton<FireBaseStorageService>(
    FireBaseStorageService(pickerassetsservice: getIt<PickerAssetsInterface>()),
  );
  getIt.registerSingleton<StorageService>(getIt<FireBaseStorageService>());
  getIt.registerSingleton<DataBaseService>(FirebaseFirestoreservice());
  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(
      authService: getIt<FirebaseAuthService>(),
      databaseservice: getIt<DataBaseService>(),
    ),
  );
  getIt.registerLazySingleton<ResetPaswordRepo>(
    () => ResetPaswordRepoImp(authService: FirebaseAuth.instance),
  );
}
