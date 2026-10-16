import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintir_dashboard/Features/Auth/Domain/Entities/TeacherWalletEntity.dart';

class TeacherWalletModel {
  final int? walletId;
  final String? teacherId;
  final double? balance;
  final double? totalEarned;
  final double? payoutPending;
  final String? currency;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? lastTransactionId;
  TeacherWalletModel({
    required this.walletId,
    required this.teacherId,
    required this.balance,
    required this.totalEarned,
    required this.payoutPending,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.lastTransactionId,
  });
  factory TeacherWalletModel.fromJson(Map<String, dynamic> json) =>
      TeacherWalletModel(
        walletId: (json['wallet_id'] as num?)?.toInt(),
        teacherId: json['teacher_id'] as String?,
        balance: _number(json['balance']),
        totalEarned: _number(json['total_earned']),
        payoutPending: _number(json['payout_pending'] ?? json['payoutPending']),
        currency: json['currency'] as String?,
        status: json['status'] as String?,
        createdAt: _date(json['created_at']),
        updatedAt: _date(json['updated_at'] ?? json['updatedAt']),
        lastTransactionId:
            (json['last_transaction_id'] ?? json['lastTransactionId'])
                as String?,
      );
  factory TeacherWalletModel.fromEntity(WalletEntity wallet) =>
      TeacherWalletModel(
        walletId: wallet.walletId,
        teacherId: wallet.teacherId,
        balance: wallet.balance,
        totalEarned: wallet.totalEarned,
        payoutPending: wallet.payoutPending,
        currency: wallet.currency,
        status: wallet.status,
        createdAt: wallet.createdAt,
        updatedAt: wallet.updatedAt,
        lastTransactionId: wallet.lastTransactionId,
      );
  WalletEntity toEntity() => WalletEntity(
    walletId: walletId ?? 0,
    teacherId: teacherId ?? '',
    balance: balance ?? 0,
    totalEarned: totalEarned ?? 0,
    payoutPending: payoutPending ?? 0,
    currency: currency ?? '',
    status: status ?? '',
    createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    lastTransactionId: lastTransactionId,
  );
  Map<String, dynamic> toJson() => {
    'wallet_id': walletId,
    'teacher_id': teacherId,
    'balance': balance,
    'total_earned': totalEarned,
    'payout_pending': payoutPending,
    'currency': currency,
    'status': status,
    'created_at': createdAt,
    'updated_at': updatedAt,
    'last_transaction_id': lastTransactionId,
  };
  static double? _number(dynamic value) =>
      value is num ? value.toDouble() : null;
  static DateTime? _date(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
