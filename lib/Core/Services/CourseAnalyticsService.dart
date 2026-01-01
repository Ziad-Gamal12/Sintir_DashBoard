import 'package:sintir_dashboard/Core/Models/CardAnalyticsModels/AnalyticsResultModel.dart';
import 'package:sintir_dashboard/Core/Services/DioService.dart';
import 'package:sintir_dashboard/Features/Dashboard/Domain/Entities/AnalyticsResultEntity.dart';

class CourseAnalyticsService {
  final DioService _dioService;
  CourseAnalyticsService(this._dioService);

  Future<AnalyticsResultEntity> _getSubStats({
    required String courseId,
    required String subCollection,
    String? sumField,
  }) async {
    final response = await _dioService.post(
      'course-analytics',
      data: {
        'courseId': courseId,
        'targetSubCollection': subCollection,
        'sumField': sumField,
      },
    );
    return AnalyticsResultModel.fromJson(response.data).toEntity();
  }

  Future<AnalyticsResultEntity> getCourseRevenue(String courseId) =>
      _getSubStats(
        courseId: courseId,
        subCollection: 'Transactions',
        sumField: 'amount',
      );

  Future<AnalyticsResultEntity> getCourseSubscribers(String courseId) =>
      _getSubStats(courseId: courseId, subCollection: 'Subscribers');

  Future<AnalyticsResultEntity> getCourseReports(String courseId) =>
      _getSubStats(courseId: courseId, subCollection: 'Reports');

  Future<AnalyticsResultEntity> getCourseFeedbacks(String courseId) =>
      _getSubStats(courseId: courseId, subCollection: 'Feedbacks');
}
