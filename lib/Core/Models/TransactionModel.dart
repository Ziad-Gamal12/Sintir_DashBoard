import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sintir_dashboard/Core/Entities/TransactionEntity.dart';

class TransactionModel {
  final String? transactionId;
  final DateTime? createdAt;
  final double? amount;
  final String? currency;
  final String? issuer;
  final String? mobile;
  final String? status;
  final bool? isReconciled;
  final String method;
  TransactionModel({
    required this.transactionId,
    required this.createdAt,
    required this.amount,
    required this.currency,
    required this.isReconciled,
    required this.method,
    required this.issuer,
    required this.mobile,
    required this.status,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      transactionId: json['transaction_id'],
      createdAt: (json['created_at'] as Timestamp).toDate(),
      amount: json['amount'],
      method: json['method'] ?? "",
      currency: json['currency'],
      isReconciled: json['isReconciled'],
      issuer: json['issuer'],
      mobile: json['mobile'],
      status: json['status'],
    );
  }
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      transactionId: entity.transactionId,
      createdAt: entity.createdAt,
      amount: entity.amount,
      currency: entity.currency,
      method: entity.method,
      isReconciled: entity.isReconciled,
      issuer: entity.issuer,
      mobile: entity.mobileNumber,
      status: entity.status,
    );
  }
  TransactionEntity toEntity() {
    return TransactionEntity(
      transactionId: transactionId,
      isReconciled: isReconciled,
      createdAt: createdAt,
      method: method,
      amount: amount,
      currency: currency,
      issuer: issuer,
      mobileNumber: mobile,
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'created_at': createdAt,
      'amount': amount,
      'isReconciled': isReconciled,
      'currency': currency,
      'issuer': issuer,
      'mobile': mobile,
      'status': status,
      'method': method,
    };
  }
}
