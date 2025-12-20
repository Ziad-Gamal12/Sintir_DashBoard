import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseSectionEntity.dart';
import 'package:sintir_dashboard/Core/Models/FileItemModels/CoursefileModel.dart';
import 'package:sintir_dashboard/Core/Models/TestItemModels/CourseTestModel.dart';
import 'package:sintir_dashboard/Core/Models/VideoItemModels/CoursevedioitemModel.dart';

class CourseSectionModel {
  final String id, title, subtitle;

  CourseSectionModel({
    required this.title,
    required this.subtitle,
    required this.id,
  });
  factory CourseSectionModel.fromEntity({
    required CourseSectionEntity coursSectionsListItemEntity,
  }) => CourseSectionModel(
    title: coursSectionsListItemEntity.title,
    subtitle: coursSectionsListItemEntity.subtitle,
    id: coursSectionsListItemEntity.id,
  );
  factory CourseSectionModel.fromJson(Map<String, dynamic> json) {
    return CourseSectionModel(
      title: json['title'],
      subtitle: json['subtitle'],
      id: json['id'],
    );
  }

  CourseSectionEntity toEntity() =>
      CourseSectionEntity(title: title, subtitle: subtitle, id: id);
  Map<String, dynamic> toJson() {
    return {"title": title, "subtitle": subtitle, "id": id};
  }

  List getItemsEntity(List<Map<String, dynamic>> items) {
    List courseItems = [];
    for (var item in items) {
      if (item["type"] == "Test") {
        courseItems.add(Coursetestmodel.fromJson(item).toEntity());
      } else if (item["type"] == "Vedio") {
        courseItems.add(CourseVideoItemModel.fromJson(item).toEntity());
      } else {
        courseItems.add(Coursefilemodel.fromJson(item).toEntity());
      }
    }
    return courseItems;
  }
}
