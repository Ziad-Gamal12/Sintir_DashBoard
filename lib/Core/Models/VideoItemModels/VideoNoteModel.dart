import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseVideoItemEntities/VideoNoteEntity.dart';
import 'package:sintir_dashboard/Features/Auth/Data/models/UserModel.dart';

class VideoNoteModel {
  final Map<String, dynamic> user;
  final DateTime dateTime;
  final String note;

  VideoNoteModel({
    required this.user,
    required this.dateTime,
    required this.note,
  });

  factory VideoNoteModel.fromJson(Map<String, dynamic> json) {
    return VideoNoteModel(
      user: json['user'],
      dateTime: (json['dateTime'] as Timestamp).toDate(),
      note: json['note'],
    );
  }

  factory VideoNoteModel.fromEntity(VideoNoteEntity entity) {
    return VideoNoteModel(
      user: UserModel.fromEntity(entity.user).toMap(),
      dateTime: entity.dateTime,
      note: entity.note,
    );
  }
  VideoNoteEntity toEntity() {
    return VideoNoteEntity(
      user: UserModel.fromJson(user).toEntity(),
      dateTime: dateTime,
      note: note,
    );
  }

  Map<String, dynamic> toMap() {
    return {'user': user, 'dateTime': dateTime, 'note': note};
  }
}
