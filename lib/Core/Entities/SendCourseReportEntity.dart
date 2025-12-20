class Sendcoursereportentity {
  final String title;
  String? description;

  Sendcoursereportentity({this.description, required this.title});

  static List<Sendcoursereportentity> reportReasons = [
    Sendcoursereportentity(title: "محتوى غير لائق"),
    Sendcoursereportentity(title: "معلومات خاطئة أو غير دقيقة"),
    Sendcoursereportentity(title: "محتوى مضلل أو خادع"),
    Sendcoursereportentity(title: "مشكلة تقنية في تشغيل الدورة"),
    Sendcoursereportentity(title: "انتهاك حقوق الملكية الفكرية"),
    Sendcoursereportentity(title: "المحتوى لا يناسب وصف الدورة"),
    Sendcoursereportentity(title: "جودة الفيديو أو الصوت رديئة"),
    Sendcoursereportentity(title: "مشكلة في السعر أو الدفع"),
    Sendcoursereportentity(title: "أسلوب تقديم غير مهني"),
    Sendcoursereportentity(title: "أسباب أخرى"),
  ];
}
