part of 'dashbaord_users_gender_analytics_cubit.dart';

@immutable
sealed class DashbaordUsersGenderAnalyticsState {}

final class DashbaordUsersGenderAnalyticsInitial
    extends DashbaordUsersGenderAnalyticsState {}

final class DashbaordUsersGenderAnalyticsLoading
    extends DashbaordUsersGenderAnalyticsState {}

final class DashbaordUsersGenderAnalyticsSuccess
    extends DashbaordUsersGenderAnalyticsState {
  final GenderAnalysisEntity genderAnalytics;
  DashbaordUsersGenderAnalyticsSuccess({required this.genderAnalytics});
}

final class DashbaordUsersGenderAnalyticsFailure
    extends DashbaordUsersGenderAnalyticsState {
  final String errMessage;
  DashbaordUsersGenderAnalyticsFailure({required this.errMessage});
}
