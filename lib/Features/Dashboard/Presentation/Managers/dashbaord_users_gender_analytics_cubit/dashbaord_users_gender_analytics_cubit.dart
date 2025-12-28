// ignore_for_file: depend_on_referenced_packages

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/GenderAnalysisEntity.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Repos/DashbaordAnalyticsRepo.dart';

part 'dashbaord_users_gender_analytics_state.dart';

class DashbaordUsersGenderAnalyticsCubit
    extends Cubit<DashbaordUsersGenderAnalyticsState> {
  DashbaordUsersGenderAnalyticsCubit({required this.dashbaordAnalyticsRepo})
    : super(DashbaordUsersGenderAnalyticsInitial());
  final DashbaordAnalyticsRepo dashbaordAnalyticsRepo;

  Future<void> analyzeUsersGender() async {
    emit(DashbaordUsersGenderAnalyticsLoading());
    final result = await dashbaordAnalyticsRepo.analyzeUsersGender();
    result.fold(
      (l) => emit(DashbaordUsersGenderAnalyticsFailure(errMessage: l.message)),
      (genderAnalytics) => emit(
        DashbaordUsersGenderAnalyticsSuccess(genderAnalytics: genderAnalytics),
      ),
    );
  }
}
