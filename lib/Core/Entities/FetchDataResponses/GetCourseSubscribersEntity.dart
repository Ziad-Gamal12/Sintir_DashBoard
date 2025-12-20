import 'package:sintir_dashboard/Core/Entities/CourseEntities/SubscriberEntity.dart';

class GetCourseSubscribersEntity {
  final List<SubscriberEntity> subscribers;
  final bool hasMore;
  final bool isPaginate;

  GetCourseSubscribersEntity({
    required this.subscribers,
    required this.hasMore,
    required this.isPaginate,
  });
}
