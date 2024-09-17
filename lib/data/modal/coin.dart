class Coin {
  final String id;
  final String name;
  final String symbol;
  final double currentPrice;
  final double priceChangePercentage24h;
  final String imageUrl;

  Coin({
    required this.id,
    required this.name,
    required this.symbol,
    required this.currentPrice,
    required this.priceChangePercentage24h,
    required this.imageUrl,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      currentPrice: json['current_price'].toDouble(),
      priceChangePercentage24h: json['price_change_percentage_24h'].toDouble(),
      imageUrl: json['image'],
    );
  }
}
