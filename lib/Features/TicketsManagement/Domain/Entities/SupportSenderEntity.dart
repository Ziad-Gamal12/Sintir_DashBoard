class SupportSenderEntity {
  String name;
  String email;
  String phone;
  String uid;
  String photoUrl;
  String role;
  SupportSenderEntity({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.uid,
    required this.photoUrl,
  });
  static SupportSenderEntity empty() {
    return SupportSenderEntity(
      name: 'محمد أحمد ',
      email: 'ziadgamail.com',
      phone: '0123456789',
      uid: '424124',
      photoUrl: 'https://cdn-icons-png.flaticon.com/128/149/149071.png',
      role: 'Student',
    );
  }
}
