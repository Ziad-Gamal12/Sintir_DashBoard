class TeacherWalletEntity {
  final int walletId;
  String teacherId;
  final double balance;
  final double totalEarned;
  final double payoutPending;
  final String currency;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? lastTransactionId;

  TeacherWalletEntity({
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
}
