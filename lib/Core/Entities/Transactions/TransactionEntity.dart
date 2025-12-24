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
  TransactionEntity({
    required this.transactionId,
    required this.createdAt,
    required this.amount,
    required this.currency,
    required this.issuer,
    required this.method,
    required this.isReconciled,
    required this.mobileNumber,
    required this.status,
  });

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

  static List<TransactionEntity> getTestTransactions() {
    return [
      TransactionEntity(
        transactionId: "TXN-1001",
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        amount: 150.0,
        currency: "USD",
        issuer: "Visa",
        method: "Credit Card",
        isReconciled: true,
        mobileNumber: "+212600000001",
        status: "success",
      ),
      TransactionEntity(
        transactionId: "TXN-1002",
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        amount: 85.50,
        currency: "USD",
        issuer: "MasterCard",
        method: "Credit Card",
        isReconciled: true,
        mobileNumber: "+212600000002",
        status: "success",
      ),
      TransactionEntity(
        transactionId: "TXN-1003",
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        amount: 210.0,
        currency: "USD",
        issuer: "Wafacash",
        method: "Mobile Wallet",
        isReconciled: false,
        mobileNumber: "+212600000003",
        status: "pending",
      ),
      TransactionEntity(
        transactionId: "TXN-1004",
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        amount: 45.0,
        currency: "USD",
        issuer: "CIH Bank",
        method: "Bank Transfer",
        isReconciled: true,
        mobileNumber: "+212600000004",
        status: "success",
      ),
      TransactionEntity(
        transactionId: "TXN-1005",
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        amount: 320.75,
        currency: "USD",
        issuer: "Visa",
        method: "Credit Card",
        isReconciled: true,
        mobileNumber: "+212600000005",
        status: "success",
      ),
      TransactionEntity(
        transactionId: "TXN-1006",
        createdAt: DateTime.now(), // Today
        amount: 190.0,
        currency: "USD",
        issuer: "CashPlus",
        method: "Cash",
        isReconciled: false,
        mobileNumber: "+212600000006",
        status: "failed",
      ),
    ];
  }
}
