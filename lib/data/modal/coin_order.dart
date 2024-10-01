class CoinOrder {
  String id;
  final String walletId;
  final String symbol;
  String type;
  double amount;
  double price;
  double? takeProfit;
  double? stopLoss;
  String status;
  DateTime createdAt;
  double currentPrice;

  CoinOrder({
    required this.id,
    required this.walletId,
    required this.symbol,
    required this.type,
    required this.amount,
    required this.price,
    this.takeProfit,
    this.stopLoss,
    required this.status,
    required this.createdAt,
    this.currentPrice = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'walletId': walletId,
      'symbol': symbol,
      'type': type,
      'amount': amount,
      'price': price,
      'takeProfit': takeProfit,
      'stopLoss': stopLoss,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CoinOrder.fromMap(Map<String, dynamic> map) {
    return CoinOrder(
      id: map['id'] ?? '',
      walletId: map['walletId'] ?? '',
      symbol: map['symbol'] ?? '',
      type: map['type'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      takeProfit: map['takeProfit'] != null
          ? (map['takeProfit'] as num).toDouble()
          : null,
      stopLoss:
          map['stopLoss'] != null ? (map['stopLoss'] as num).toDouble() : null,
      status: map['status'] ?? 'open',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}
