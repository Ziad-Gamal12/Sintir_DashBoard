import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintir_dashboard/Core/Entities/CourseEntities/CourseCouponEntity.dart';

class CourseCouponModel {
  final String code;
  final double discountPercentage;
  final DateTime expiryDate;
  final bool isActive;
  final int usageLimit;
  final int usedCount;

  CourseCouponModel({
    required this.code,
    required this.discountPercentage,
    required this.expiryDate,
    required this.isActive,
    required this.usageLimit,
    required this.usedCount,
  });

  factory CourseCouponModel.fromJson(Map<String, dynamic> json) {
    return CourseCouponModel(
      code: json['code'],
      discountPercentage: (json['discountPercentage'] as num).toDouble(),
      expiryDate: (json['expiryDate'] as Timestamp).toDate(),
      isActive: json['isActive'],
      usageLimit: (json['usageLimit'] as num).toInt(),
      usedCount: (json['usedCount'] as num).toInt(),
    );
  }
  factory CourseCouponModel.fromEntity(CourseCouponEntity entity) {
    return CourseCouponModel(
      code: entity.code,
      discountPercentage: entity.discountPercentage,
      expiryDate: entity.expiryDate,
      isActive: entity.isActive,
      usageLimit: entity.usageLimit,
      usedCount: entity.usedCount,
    );
  }
  CourseCouponEntity toEntity() {
    return CourseCouponEntity(
      code: code,
      discountPercentage: discountPercentage,
      expiryDate: expiryDate,
      isActive: isActive,
      usageLimit: usageLimit,
      usedCount: usedCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'discountPercentage': discountPercentage,
      'expiryDate': expiryDate,
      'isActive': isActive,
      'usageLimit': usageLimit,
      'usedCount': usedCount,
    };
  }
}
