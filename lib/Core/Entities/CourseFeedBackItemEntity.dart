class CoursefeedbackItemEntity {
  String userImage, uid, name, fedBack;
  final DateTime datePosted;

  CoursefeedbackItemEntity(
      {required this.userImage,
      required this.name,
      required this.uid,
      required this.fedBack,
      required this.datePosted});
  static CoursefeedbackItemEntity empty() => CoursefeedbackItemEntity(
      userImage: "https://cdn-icons-png.flaticon.com/128/6356/6356630.png",
      name: "loading",
      uid: "loading",
      fedBack: "loading",
      datePosted: DateTime.now());
}
