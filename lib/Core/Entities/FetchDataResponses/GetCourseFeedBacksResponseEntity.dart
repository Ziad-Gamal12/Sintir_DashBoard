import 'package:sintir_dashboard/Core/Entities/CourseFeedBackItemEntity.dart';

class GetCourseFeedBacksResponseEntity {
  final List<CoursefeedbackItemEntity> feedBacks;
  final bool hasMore;
  final bool isPaginate;
  GetCourseFeedBacksResponseEntity({
    required this.feedBacks,
    required this.hasMore,
    required this.isPaginate,
  });
}
