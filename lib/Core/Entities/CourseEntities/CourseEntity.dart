// ignore_for_file: file_names

import 'package:sintir_dashboard/Core/Entities/CourseEntities/ContentCreaterEntity.dart';

class CourseEntity {
  String id, title, description, language, state;
  int price;
  final int studentsCount;
  String? posterUrl;
  final DateTime postedDate;
  final String subject;
  final String level;
  ContentCreatorEntity? contentcreaterentity;

  CourseEntity({
    required this.id,
    required this.state,
    this.posterUrl,
    required this.studentsCount,
    required this.subject,
    required this.level,
    required this.title,
    required this.description,
    required this.price,
    required this.language,
    required this.postedDate,
    this.contentcreaterentity,
  });
  factory CourseEntity.empty() => CourseEntity(
    id: '41421231414',
    state: "Published",
    title: 'كورس تجريبي',
    description: 'هذا وصف تجريبي للكورس',
    contentcreaterentity: ContentCreatorEntity.empty(),
    posterUrl:
        "https://foundr.com/wp-content/uploads/2021/09/Best-online-course-platforms.png",
    price: 120,
    language: 'العربية',
    subject: 'تطوير الويب',
    level: 'مبتدئ',
    postedDate: DateTime.now(),
    studentsCount: 3,
  );
  static List<CourseEntity> fakeCourses = List.generate(
    10,
    (index) => CourseEntity.empty(),
  );
}
