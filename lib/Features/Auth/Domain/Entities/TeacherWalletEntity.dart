class WalletEntity {
  int walletId;
  String teacherId;
  double balance;
  double totalEarned;
  double payoutPending;
  String currency;
  String status;
  String createdAt;
  String updatedAt;
  String? lastTransactionId;

  WalletEntity({
    required this.walletId,
    required this.teacherId,
    required this.balance,
    required this.totalEarned,
    required this.payoutPending,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastTransactionId,
  });

  WalletEntity copyWith({
    int? walletId,
    String? teacherId,
    double? balance,
    double? totalEarned,
    double? payoutPending,
    String? currency,
    String? status,
    String? createdAt,
    String? updatedAt,
    String? lastTransactionId,
  }) {
    return WalletEntity(
      walletId: walletId ?? this.walletId,
      teacherId: teacherId ?? this.teacherId,
      balance: balance ?? this.balance,
      totalEarned: totalEarned ?? this.totalEarned,
      payoutPending: payoutPending ?? this.payoutPending,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastTransactionId: lastTransactionId ?? this.lastTransactionId,
    );
  }

  static WalletEntity empty() {
    return WalletEntity(
      walletId: 0,
      teacherId: '',
      balance: 0.0,
      totalEarned: 0.0,
      payoutPending: 0.0,
      currency: '',
      status: '',
      createdAt: '',
      updatedAt: '',
      lastTransactionId: '',
    );
  }
}
