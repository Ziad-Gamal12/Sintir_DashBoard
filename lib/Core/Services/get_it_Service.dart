// ignore_for_file: file_names, non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/Services/FireBase/FirebaseAuth_Service.dart';
import 'package:sintir_dashboard/Core/Services/FireBase/Firebase_FirestoreService.dart';
import 'package:sintir_dashboard/Core/Services/FireBase/firebaseStorageService.dart';
import 'package:sintir_dashboard/Core/Services/PickerAssetsServiceMobile.dart';
import 'package:sintir_dashboard/Core/Services/StorageService.dart';
import 'package:sintir_dashboard/Core/Services/picker_assets_interface.dart';

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
}
