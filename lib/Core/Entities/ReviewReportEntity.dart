// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewReportEntity {
  const ReviewReportEntity({
    required this.courseId,
    required this.reviewUid,
    required this.reportedBy,
    required this.reporterRole,
    required this.reason,
    required this.details,
    this.createdAt,
  });

  final String courseId;
  final String reviewUid;
  final String reportedBy;
  final String reporterRole;
  final String reason;
  final String details;
  final DateTime? createdAt;

  String get id => '${courseId}_${reviewUid}_$reportedBy';

  factory ReviewReportEntity.fromJson(Map<String, dynamic> json) {
    String text(Object? value) => value is String ? value : '';
    final created = json['createdAt'];
    return ReviewReportEntity(
      courseId: text(json['courseId']),
      reviewUid: text(json['reviewUid']),
      reportedBy: text(json['reportedBy']),
      reporterRole: text(json['reporterRole']),
      reason: text(json['reason']),
      details: text(json['details']),
      createdAt: created is Timestamp ? created.toDate() : null,
    );
  }

  static const Map<String, String> reasonLabels = {
    'offensive': 'ألفاظ مسيئة',
    'harassment': 'إساءة أو تهديد',
    'spam': 'إعلان أو رسائل مزعجة',
    'personal_info': 'بيانات شخصية',
    'irrelevant': 'لا علاقة له بالكورس',
    'other': 'سبب آخر',
  };

  String get reasonLabel => reasonLabels[reason] ?? reason;

  static Map<String, List<ReviewReportEntity>> groupByReview(
    Iterable<Map<String, dynamic>> rows,
  ) {
    final grouped = <String, List<ReviewReportEntity>>{};
    for (final row in rows) {
      final report = ReviewReportEntity.fromJson(row);
      if (report.reviewUid.isEmpty) continue;
      grouped.putIfAbsent(report.reviewUid, () => []).add(report);
    }
    return grouped;
  }
}
