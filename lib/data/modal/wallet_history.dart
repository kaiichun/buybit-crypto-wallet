class WalletHistory {
  final String id;
  final String walletId;
  final String action; 
  final double amount;
  final DateTime date;

  WalletHistory({
    required this.id,
    required this.walletId,
    required this.action,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'walletId': walletId,
      'action': action,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  factory WalletHistory.fromMap(Map<String, dynamic> map) {
    return WalletHistory(
      id: map['id'],
      walletId: map['walletId'],
      action: map['action'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
    );
  }
}
