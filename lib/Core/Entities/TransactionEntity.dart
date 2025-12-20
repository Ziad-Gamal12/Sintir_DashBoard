class TransactionEntity {
  String? transactionId;
  final DateTime? createdAt;
  final double? amount;
  final String? currency;
  final String? issuer;
  final String? mobileNumber;
  final String? status;
  final bool? isReconciled;
  final String method;
  TransactionEntity(
      {required this.transactionId,
      required this.createdAt,
      required this.amount,
      required this.currency,
      required this.issuer,
      required this.method,
      required this.isReconciled,
      required this.mobileNumber,
      required this.status});

  TransactionEntity copyWith({
    String? transactionId,
    DateTime? createdAt,
    double? amount,
    String? currency,
    String? issuer,
    String? mobileNumber,
    bool? isReconciled,
    String? status,
  }) {
    return TransactionEntity(
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      method: method,
      isReconciled: isReconciled ?? this.isReconciled,
      issuer: issuer ?? this.issuer,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      status: status ?? this.status,
    );
  }

  static List<TransactionEntity> getFakeTransactions() {
    return List.generate(
        6,
        (index) => TransactionEntity(
              transactionId: "transactionId",
              createdAt: DateTime.now(),
              amount: 0.0,
              currency: "EGP",
              issuer: "issuer",
              method: "method",
              isReconciled: false,
              mobileNumber: "mobileNumber",
              status: "status",
            ));
  }
}
