class JoinedByEntity {
  final String uid, name, imageUrl;
  final DateTime joinedDate;
  JoinedByEntity(
      {required this.uid,
      required this.name,
      required this.imageUrl,
      required this.joinedDate});
 static JoinedByEntity empty() {
    return JoinedByEntity(
        uid: "loading",
        name: "loading",
        imageUrl: "https://cdn-icons-png.flaticon.com/128/149/149071.png",
        joinedDate: DateTime.now());
  }
}
