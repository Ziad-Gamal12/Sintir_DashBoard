// ignore_for_file: file_names

class Contentcreaterentity {
  final String name, profileImageUrl, id, title;

  Contentcreaterentity(
      {required this.name,
      required this.profileImageUrl,
      required this.id,
      required this.title});
  static Contentcreaterentity empty() => Contentcreaterentity(
        name: 'loading',
        profileImageUrl:
            'https://cdn-icons-png.flaticon.com/128/149/149071.png',
        id: 'loading',
        title: 'loading',
      );
}
