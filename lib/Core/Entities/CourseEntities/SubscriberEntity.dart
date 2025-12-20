// ignore_for_file: file_names

class SubscriberEntity {
  final String id;
  final String name, gender, phone, educationLevel, imageUrl, address;

  SubscriberEntity(
      {required this.id,
      required this.name,
      required this.gender,
      required this.phone,
      required this.educationLevel,
      required this.imageUrl,
      required this.address});
  static SubscriberEntity empty() => SubscriberEntity(
        id: 'loading',
        name: 'loading',
        gender: 'loading',
        phone: 'loading',
        educationLevel: 'loading',
        imageUrl: 'loading',
        address: 'loading',
      );
}
