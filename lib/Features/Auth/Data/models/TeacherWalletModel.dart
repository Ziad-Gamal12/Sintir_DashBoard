import 'package:sintir_dashboard/Features/Auth/Domain/Entities/TeacherWalletEntity.dart';

class TeacherWalletModel {
  final int walletId;
  final String teacherId;
  final double balance;
  final double totalEarned;
  final double payoutPending;
  final String currency;
  final String status;
  final String createdAt;
  final String updatedAt;
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
  factory TeacherWalletModel.fromJson(Map<String, dynamic> json) {
    return TeacherWalletModel(
      walletId: json['wallet_id'],
      teacherId: json['teacher_id'],
      balance: (json['balance'] as num).toDouble(),
      totalEarned: (json['total_earned'] as num).toDouble(),
      payoutPending: (json['payout_pending'] as num).toDouble(),
      currency: json['currency'],
      status: json['status'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'] ?? '',
      lastTransactionId: json['last_transaction_id'] ?? '',
    );
  }
  factory TeacherWalletModel.fromEntity(WalletEntity teacherWalletEntity) {
    return TeacherWalletModel(
      walletId: teacherWalletEntity.walletId,
      teacherId: teacherWalletEntity.teacherId,
      balance: teacherWalletEntity.balance,
      totalEarned: teacherWalletEntity.totalEarned,
      payoutPending: teacherWalletEntity.payoutPending,
      currency: teacherWalletEntity.currency,
      status: teacherWalletEntity.status,
      createdAt: teacherWalletEntity.createdAt,
      updatedAt: teacherWalletEntity.updatedAt,
      lastTransactionId: teacherWalletEntity.lastTransactionId,
    );
  }

  WalletEntity toEntity() {
    return WalletEntity(
      walletId: walletId,
      teacherId: teacherId,
      balance: balance,
      totalEarned: totalEarned,
      payoutPending: payoutPending,
      currency: currency,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastTransactionId: lastTransactionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
  }
}
