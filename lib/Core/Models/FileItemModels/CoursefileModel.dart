import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseFileItemEntities/CourseFileEntity.dart';

class Coursefilemodel {
  final String title;
  final String filePath;
  final String description;
  final String id;
  String? type;

  Coursefilemodel({
    required this.title,
    required this.filePath,
    required this.description,
    required this.id,
    this.type = "File",
  });
  factory Coursefilemodel.fromJson(Map<String, dynamic> json) {
    return Coursefilemodel(
      id: json['id'],
      title: json['title'],
      filePath: json['filePath'],
      description: json['description'],
      type: json['type'],
    );
  }
  factory Coursefilemodel.fromEntity(CourseFileEntity coursefileentity) {
    return Coursefilemodel(
      id: coursefileentity.id,
      title: coursefileentity.title,
      filePath: coursefileentity.fileUrl,
      description: coursefileentity.description,
      type: coursefileentity.type,
    );
  }
  CourseFileEntity toEntity() => CourseFileEntity(
    id: id,
    title: title,
    fileUrl: filePath,
    description: description,
    type: type,
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'filePath': filePath,
    'description': description,
    'type': type,
    'id': id,
  };
}
