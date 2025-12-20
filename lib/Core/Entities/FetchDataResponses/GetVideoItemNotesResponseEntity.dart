import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseVideoItemEntities/VideoNoteEntity.dart';

class GetVideoItemNotesResponseEntity {
  final List<VideoNoteEntity> notes;
  final bool hasMore;
  final bool isPaginate;

  GetVideoItemNotesResponseEntity({
    required this.notes,
    required this.hasMore,
    required this.isPaginate,
  });
}
