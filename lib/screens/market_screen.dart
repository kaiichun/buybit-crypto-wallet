import 'package:buybit/data/api/api_service.dart';
import 'package:buybit/data/modal/coin.dart';
import 'package:flutter/material.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  late Future<List<Coin>> _futureCoins;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _futureCoins = _apiService.fetchCoins();
  }

  String formatPrice(double price) {
    if (price < 1) {
      return '\$${price.toString()}';
    } else {
      return '\$${price.toStringAsFixed(2)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 58, 166, 254),
        title: const Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Market',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          FutureBuilder<List<Coin>>(
            future: _futureCoins,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading data, please wait...'),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No data found'));
              } else {
                final coins = snapshot.data!;
                return Column(
                  children: coins.map((coin) {
                    return marketItem(
                        coin.id,
                        coin.symbol.toUpperCase(),
                        coin.name,
                        formatPrice(coin.currentPrice),
                        '${coin.priceChangePercentage24h.toStringAsFixed(2)}%',
                        coin.priceChangePercentage24h >= 0,
                        coin.imageUrl);
                  }).toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget marketItem(String id, String pair, String name, String price,
      String percentage, bool isPositive, String imageUrl) {
    String letTextBecomeDot(String text, int wordLimit) {
      List<String> words = text.split(' ');
      if (words.length > wordLimit) {
        return words.take(wordLimit).join(' ') + '...';
      } else {
        return text;
      }
    }

    return Card(
      elevation: 2,
      color: const Color.fromARGB(255, 240, 240, 240),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.network(
                  imageUrl,
                  height: 40,
                  width: 40,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, size: 40);
                  },
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pair,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(letTextBecomeDot(name, 2)),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    Text(
                      percentage,
                      style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
