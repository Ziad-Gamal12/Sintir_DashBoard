import 'package:equatable/equatable.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/AnalyticsResultEntity.dart';

class DashbaordAnalyticsState extends Equatable {
  final AnalyticsResultEntity? revenue;
  final AnalyticsResultEntity? users;
  final AnalyticsResultEntity? courses;
  final AnalyticsResultEntity? tickets;
  final bool isLoadingRevenue;
  final bool isLoadingUsers;
  final bool isLoadingCourses;
  final bool isLoadingTickets;

  const DashbaordAnalyticsState({
    this.revenue,
    this.users,
    this.courses,
    this.tickets,
    this.isLoadingRevenue = false,
    this.isLoadingUsers = false,
    this.isLoadingCourses = false,
    this.isLoadingTickets = false,
  });

  DashbaordAnalyticsState copyWith({
    AnalyticsResultEntity? revenue,
    AnalyticsResultEntity? users,
    AnalyticsResultEntity? courses,
    AnalyticsResultEntity? tickets,
    bool? isLoadingRevenue,
    bool? isLoadingUsers,
    bool? isLoadingCourses,
    bool? isLoadingTickets,
  }) {
    return DashbaordAnalyticsState(
      revenue: revenue ?? this.revenue,
      users: users ?? this.users,
      courses: courses ?? this.courses,
      tickets: tickets ?? this.tickets,
      isLoadingRevenue: isLoadingRevenue ?? this.isLoadingRevenue,
      isLoadingUsers: isLoadingUsers ?? this.isLoadingUsers,
      isLoadingCourses: isLoadingCourses ?? this.isLoadingCourses,
      isLoadingTickets: isLoadingTickets ?? this.isLoadingTickets,
    );
  }

  @override
  List<Object?> get props => [
    revenue,
    users,
    courses,
    tickets,
    isLoadingRevenue,
    isLoadingUsers,
    isLoadingCourses,
    isLoadingTickets,
  ];
}
