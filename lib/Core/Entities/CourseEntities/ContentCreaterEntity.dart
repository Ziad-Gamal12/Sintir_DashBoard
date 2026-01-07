// ignore_for_file: file_names

class ContentCreatorEntity {
  final String name, profileImageUrl, id, title;

  ContentCreatorEntity({
    required this.name,
    required this.profileImageUrl,
    required this.id,
    required this.title,
  });
  static ContentCreatorEntity empty() => ContentCreatorEntity(
    name: 'مستخدم تجريبي',
    profileImageUrl: 'https://cdn-icons-png.flaticon.com/128/149/149071.png',
    id: '4124156125',
    title: '',
  );
}
