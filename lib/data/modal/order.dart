class Order {
  final String id;
  final String coinId;
  final double entryPrice;
  final double takeProfitPrice;
  final double stopLossPrice;
  final double lotSize;
  final int leverage;
  final double currentPrice;
  final bool isClosed;
  final DateTime openTime;

  Order({
    required this.id,
    required this.coinId,
    required this.entryPrice,
    required this.takeProfitPrice,
    required this.stopLossPrice,
    required this.lotSize,
    required this.leverage,
    required this.currentPrice,
    required this.isClosed,
    required this.openTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'coinId': coinId,
      'entryPrice': entryPrice,
      'takeProfitPrice': takeProfitPrice,
      'stopLossPrice': stopLossPrice,
      'lotSize': lotSize,
      'leverage': leverage,
      'currentPrice': currentPrice,
      'isClosed': isClosed,
      'openTime': openTime.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      coinId: map['coinId'],
      entryPrice: map['entryPrice'],
      takeProfitPrice: map['takeProfitPrice'],
      stopLossPrice: map['stopLossPrice'],
      lotSize: map['lotSize'],
      leverage: map['leverage'],
      currentPrice: map['currentPrice'],
      isClosed: map['isClosed'],
      openTime: DateTime.parse(map['openTime']),
    );
  }
}
