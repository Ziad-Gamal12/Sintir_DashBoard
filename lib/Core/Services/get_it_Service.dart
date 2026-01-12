// ignore_for_file: file_names, non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:sintir_dashboard/Core/Services/CourseAnalyticsService.dart';
import 'package:sintir_dashboard/Core/Services/DataBaseService.dart';
import 'package:sintir_dashboard/Core/Services/DioService.dart';
import 'package:sintir_dashboard/Core/Services/FireBase/FirebaseAuth_Service.dart';
import 'package:sintir_dashboard/Core/Services/FireBase/Firebase_FirestoreService.dart';
import 'package:sintir_dashboard/Core/Services/FireBase/firebaseStorageService.dart';
import 'package:sintir_dashboard/Core/Services/PickerAssetsServiceMobile.dart';
import 'package:sintir_dashboard/Core/Services/StorageService.dart';
import 'package:sintir_dashboard/Core/Services/SupabaseAnalyticsService.dart';
import 'package:sintir_dashboard/Core/Services/picker_assets_interface.dart';
import 'package:sintir_dashboard/Core/repos/ContentCreatorRepos/ContentCreatorProfileRepo.dart';
import 'package:sintir_dashboard/Core/repos/ContentCreatorRepos/ContentCreatorProfileRepoImpl.dart';
import 'package:sintir_dashboard/Core/repos/CoursesRepo/CoursesRepo.dart';
import 'package:sintir_dashboard/Core/repos/CoursesRepo/CoursesRepo_impl.dart';
import 'package:sintir_dashboard/Core/repos/ResetPaswordRepo/ResetPaswordRepo.dart';
import 'package:sintir_dashboard/Core/repos/ResetPaswordRepo/ResetPaswordRepoImp.dart';
import 'package:sintir_dashboard/Features/Auth/Data/repos/AuthRepoImpl.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Repos/AuthRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Data/Repos/CourseAnalyticsRepoImpl.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Data/Repos/CourseFeedBacksRepoImpli.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Data/Repos/CourseReportsRepoImpli.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Data/Repos/CourseSectionsRepo_impl.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Data/Repos/CourseTransactionsRepoImpl.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseAnalyticsRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseFeedBacksRepo/CourseFeedBacksRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseReportsRepo/CourseReportsRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseSectionsRepos/CourseSectionsRepo.dart';
import 'package:sintir_dashboard/Features/CourseDetails/Domain/Repos/CourseTransactionsRepo.dart';
import 'package:sintir_dashboard/Features/Dashboard/Data/Repos/DashbaordAnalyticsRepoImpl.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Repos/DashbaordAnalyticsRepo.dart';
import 'package:sintir_dashboard/Features/Support/Data/Repos/SupportAnalyticsRepoImpl.dart';
import 'package:sintir_dashboard/Features/Support/Data/Repos/SupportChatRepoImpl.dart';
import 'package:sintir_dashboard/Features/Support/Data/Repos/SupportTicketsRepoImpl.dart';
import 'package:sintir_dashboard/Features/Support/Data/Services/SupportAnalyticsService.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Repos/SupportAnalyticsRepo.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Repos/SupportChatRepo.dart';
import 'package:sintir_dashboard/Features/Support/Domain/Repos/SupportTicketsRepo.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Data/Repos/UsersRepoImpl.dart';
import 'package:sintir_dashboard/Features/UsersManagement/Domain/Repos/UsersRepo.dart';

final getIt = GetIt.instance;

void setup_Getit() {
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService());
  getIt.registerSingleton<PickerAssetsInterface>(PickerAssetsService());
  getIt.registerSingleton<DioService>(DioService());
  getIt.registerSingleton<SupabaseAnalyticsService>(
    SupabaseAnalyticsService(getIt<DioService>()),
  );
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

  getIt.registerLazySingleton<DashbaordAnalyticsRepo>(
    () => DashbaordAnalyticsRepoImpl(
      supabaseAnalyticsService: getIt<SupabaseAnalyticsService>(),
      dataBaseService: getIt<DataBaseService>(),
    ),
  );
  getIt.registerLazySingleton<CourseAnalyticsService>(
    () => CourseAnalyticsService(getIt<DioService>()),
  );
  getIt.registerLazySingleton<Coursesrepo>(
    () => CoursesrepoImpl(
      databaseservice: getIt<DataBaseService>(),
      storageService: getIt<StorageService>(),
    ),
  );
  getIt.registerLazySingleton<CourseSectionsRepo>(
    () => CourseSectionsRepoImpl(datebaseservice: getIt<DataBaseService>()),
  );
  getIt.registerLazySingleton<ContentCreatorProfileRepo>(
    () => ContentCreatorProfileRepoImpl(
      dataBaseService: getIt<DataBaseService>(),
    ),
  );

  getIt.registerLazySingleton<CourseAnalyticsRepo>(
    () => CourseAnalyticsRepoImpl(
      courseAnalyticsService: getIt<CourseAnalyticsService>(),
    ),
  );
  getIt.registerLazySingleton<CourseReportsRepo>(
    () => CourseReportsRepoimpli(databaseservice: getIt<DataBaseService>()),
  );

  getIt.registerLazySingleton<CourseFeedBacksRepo>(
    () => CourseFeedBacksRepoImpli(databaseservice: getIt<DataBaseService>()),
  );
  getIt.registerLazySingleton<CourseTransactionsRepo>(
    () => CourseTransactionsRepoImpl(databaseService: getIt<DataBaseService>()),
  );
  getIt.registerLazySingleton<SupportTicketsRepo>(
    () => SupportTicketsRepoImpl(dataBaseService: getIt<DataBaseService>()),
  );
  getIt.registerLazySingleton<SupportChatRepo>(
    () => SupportChatRepoImpl(
      dataBaseService: getIt<DataBaseService>(),
      pickerassetsservice: getIt<PickerAssetsInterface>(),
      storageService: getIt<StorageService>(),
    ),
  );
  getIt.registerLazySingleton<SupportAnalyticsService>(
    () => SupportAnalyticsService(getIt<DioService>()),
  );
  getIt.registerLazySingleton<SupportAnalyticsRepo>(
    () => SupportAnalyticsRepoImpl(
      supportAnalyticsService: getIt<SupportAnalyticsService>(),
    ),
  );
  getIt.registerLazySingleton<UsersRepo>(
    () => UsersRepoImpl(dataBaseService: getIt<DataBaseService>()),
  );
}
