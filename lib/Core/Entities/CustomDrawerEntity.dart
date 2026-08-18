import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomDrawerEntity {
  final String title;
  final FaIconData icon;

  CustomDrawerEntity({required this.title, required this.icon});

  static List<CustomDrawerEntity> getDrawerItems() => [
    CustomDrawerEntity(title: "الرئيسية", icon: FontAwesomeIcons.house),
    CustomDrawerEntity(title: "الدورات", icon: FontAwesomeIcons.bookOpen),
    CustomDrawerEntity(title: "المستخدمين", icon: FontAwesomeIcons.users),
    CustomDrawerEntity(title: "الدعم", icon: FontAwesomeIcons.headset),
  ];
}
