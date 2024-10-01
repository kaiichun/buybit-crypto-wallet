class Coin {
  final String symbol;
  final double lastPrice;
  final double priceChangePercentage24h;
  final double volume;

  Coin({
    required this.symbol,
    required this.lastPrice,
    required this.priceChangePercentage24h,
    required this.volume,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      symbol: json['symbol'],
      lastPrice: double.tryParse(json['lastPrice']) ?? 0.0,
      priceChangePercentage24h:
          double.tryParse(json['priceChangePercent']) ?? 0.0,
      volume: double.tryParse(json['volume']) ?? 0.0,
    );
  }

  factory Coin.fromWebSocketJson(Map<String, dynamic> json) {
    return Coin(
      symbol: json['s'],
      lastPrice: double.tryParse(json['c']) ?? 0.0,
      priceChangePercentage24h: double.tryParse(json['P']) ?? 0.0,
      volume: double.tryParse(json['v']) ?? 0.0,
    );
  }
}
