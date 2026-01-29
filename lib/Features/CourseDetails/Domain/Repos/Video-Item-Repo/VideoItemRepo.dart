// ignore_for_file: file_names

import 'package:dartz/dartz.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseVideoItemEntities/CourseVedioItemEntity.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseVideoItemEntities/VideoNoteEntity.dart';
import 'package:sintir_dashboard/Core/Entities/FetchDataResponses/GetVideoItemNotesResponseEntity.dart';
import 'package:sintir_dashboard/Core/Errors/Failures.dart';

abstract class VideoItemRepo {
  Future<Either<Failure, String>> uploadVideo({
    required CourseVideoItemEntity coursevedioitementity,
  });
  Future<Either<Failure, void>> addVideoNote({
    required String coursId,
    required String sectionId,
    required String videoId,
    required VideoNoteEntity note,
  });
  Future<Either<Failure, int>> getAttendedCount({
    required String courseId,
    required String sectionId,
    required String videoId,
  });
  Future<Either<Failure, GetVideoItemNotesResponseEntity>> getVideoItemNotes({
    required String courseId,
    required String sectionId,
    required bool isPaginate,
    required String videoId,
  });
}
