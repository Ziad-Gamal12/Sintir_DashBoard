import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Repos/DashbaordAnalyticsRepo.dart';

import 'dashbaord_analytics_state.dart';

class DashbaordAnalyticsCubit extends Cubit<DashbaordAnalyticsState> {
  final DashbaordAnalyticsRepo dashbaordAnalyticsRepo;

  DashbaordAnalyticsCubit({required this.dashbaordAnalyticsRepo})
    : super(const DashbaordAnalyticsState());

  Future<void> getUserGrowth() async {
    emit(state.copyWith(isLoadingUsers: true));
    final result = await dashbaordAnalyticsRepo.getUserGrowth();
    result.fold(
      (l) => emit(state.copyWith(isLoadingUsers: false)),
      (r) => emit(state.copyWith(users: r, isLoadingUsers: false)),
    );
  }

  Future<void> getTicketStats() async {
    emit(state.copyWith(isLoadingTickets: true));
    final result = await dashbaordAnalyticsRepo.getTicketStats();
    result.fold(
      (l) => emit(state.copyWith(isLoadingTickets: false)),
      (r) => emit(state.copyWith(tickets: r, isLoadingTickets: false)),
    );
  }

  Future<void> getRevenueStats() async {
    emit(state.copyWith(isLoadingRevenue: true));
    final result = await dashbaordAnalyticsRepo.getRevenueStats();
    result.fold(
      (l) => emit(state.copyWith(isLoadingRevenue: false)),
      (r) => emit(state.copyWith(revenue: r, isLoadingRevenue: false)),
    );
  }

  Future<void> getLiveCourseStats() async {
    emit(state.copyWith(isLoadingCourses: true));
    final result = await dashbaordAnalyticsRepo.getLiveCourseStats();
    result.fold(
      (l) => emit(state.copyWith(isLoadingCourses: false)),
      (r) => emit(state.copyWith(courses: r, isLoadingCourses: false)),
    );
  }

  Future<void> fetchAll() async {
    await Future.wait([
      getRevenueStats(),
      getUserGrowth(),
      getLiveCourseStats(),
      getTicketStats(),
    ]);
  }
}
