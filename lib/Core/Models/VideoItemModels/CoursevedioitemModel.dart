import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseVideoItemEntities/CourseVedioItemEntity.dart';

class CourseVideoItemModel {
  final String title, vedioUrl;
  final int durationTime;
  final String id;
  String? type;

  CourseVideoItemModel({
    required this.title,
    required this.vedioUrl,
    required this.durationTime,
    required this.id,
    this.type = "Video",
  });
  factory CourseVideoItemModel.fromJson(Map<String, dynamic> json) =>
      CourseVideoItemModel(
        id: json['id'],
        title: json['title'],
        vedioUrl: json['vedioUrl'],
        durationTime: json['durationTime'],
        type: json['type'],
      );
  factory CourseVideoItemModel.fromEntity(CourseVideoItemEntity entity) =>
      CourseVideoItemModel(
        id: entity.id,
        title: entity.title,
        vedioUrl: entity.vedioUrl,
        durationTime: entity.durationTime,
        type: entity.type,
      );
  CourseVideoItemEntity toEntity() => CourseVideoItemEntity(
    id: id,
    title: title,
    vedioUrl: vedioUrl,
    durationTime: durationTime,
    type: type,
  );
  Map<String, dynamic> toJson() => {
    'title': title,
    'vedioUrl': vedioUrl,
    'durationTime': durationTime,
    'type': type,
    'id': id,
  };
}
