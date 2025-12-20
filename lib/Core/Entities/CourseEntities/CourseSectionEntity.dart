// ignore_for_file: file_names

class CourseSectionEntity {
  String id, title, subtitle;
  List? items;
  CourseSectionEntity(
      {required this.title,
      required this.subtitle,
      this.items,
      required this.id});
  static CourseSectionEntity empty() => CourseSectionEntity(
      title: "جاري التحميل ...", subtitle: "جاري التحميل ...", id: "    ");
}
