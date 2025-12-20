import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintir_dashboard/Core/Entities/JoinedByEntity.dart';

class JoinedbyModel {
  final String uid, name, imageUrl;
  final DateTime joinedDate;

  JoinedbyModel(
      {required this.uid,
      required this.name,
      required this.imageUrl,
      required this.joinedDate});
  factory JoinedbyModel.fromJson(Map<String, dynamic> json) {
    return JoinedbyModel(
      uid: json['uid'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      joinedDate: (json['joinedDate'] as Timestamp).toDate(),
    );
  }
  factory JoinedbyModel.fromEntity(JoinedByEntity entity) {
    return JoinedbyModel(
      uid: entity.uid,
      name: entity.name,
      imageUrl: entity.imageUrl,
      joinedDate: entity.joinedDate,
    );
  }

  JoinedByEntity toEntity() => JoinedByEntity(
      uid: uid, name: name, imageUrl: imageUrl, joinedDate: joinedDate);
  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'imageUrl': imageUrl,
        'joinedDate': joinedDate
      };
}
