import 'package:buybit/data/api/api_service.dart';
import 'package:buybit/data/modal/coin.dart';
import 'package:buybit/data/provider/favorite_coin_provider.dart';
import 'package:buybit/screens/market_coin_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});
  @override
  _MarketScreenState createState() => _MarketScreenState();
}
class _MarketScreenState extends State<MarketScreen> {
  final ApiService _apiService = ApiService();
  TextEditingController searchBarController = TextEditingController();
  List<Coin> _filteredCoins = [];
  List<Coin> _allCoins = [];
  String _currentQuery = "";
  @override
  void initState() {
    super.initState();
    _apiService.streamRealTimePrices().listen((coinList) {
      if (_currentQuery.isEmpty) {
        setState(() {
          _allCoins =
              coinList.where((coin) => coin.symbol.endsWith('USDT')).toList();
          _filteredCoins = _allCoins;
        });
      }
    });
    searchBarController.addListener(_filterCoins);
    Provider.of<FavoriteCoinProvider>(context, listen: false).loadFavorites();
  }
  @override
  void dispose() {
    _apiService.closeWebSocket();
    searchBarController.dispose();
    super.dispose();
  }
  void _filterCoins() {
    String query = searchBarController.text.toLowerCase().trim();
    _currentQuery = query;
    if (query.isEmpty) {
      setState(() {
        _filteredCoins = _allCoins;
      });
    } else {
      setState(() {
        _filteredCoins = _allCoins.where((coin) {
          return coin.symbol.toLowerCase().contains(query);
        }).toList();
      });
    }
  }
  String formatPrice(double price) {
    if (price < 0) {
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
            Icon(
              Icons.currency_exchange,
              color: Color.fromARGB(255, 41, 41, 41),
            ),
            SizedBox(width: 8),
            Text(
              'Market',
              style: TextStyle(
                color: Color.fromARGB(255, 41, 41, 41),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchBarController,
              decoration: InputDecoration(
                hintText: 'Search coin...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredCoins.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Consumer<FavoriteCoinProvider>(
                    builder: (context, favoriteProvider, child) {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        itemCount: _filteredCoins.length,
                        itemBuilder: (context, index) {
                          final coin = _filteredCoins[index];
                          final isFavorite = favoriteProvider.isFavorite(coin);
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MarketCoinDetailScreen(coinId: coin.symbol),
                                ),
                              );
                            },
                            child: coinItemCard(
                              coin.symbol.toUpperCase(),
                              formatPrice(coin.lastPrice),
                              ' ${coin.priceChangePercentage24h.toStringAsFixed(2)}% ',
                              coin.priceChangePercentage24h >= 0,
                              '${coin.volume.toStringAsFixed(2)}M',
                              isFavorite,
                              () {
                                favoriteProvider.toggleFavorite(coin);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
    Widget coinItemCard(
    String symbol,
    String price,
    String percentage,
    bool isPositive,
    String volume,
    bool isFavorite,
    VoidCallback onFavoriteToggle,
  ) {
    return Card(
      color: const Color.fromARGB(255, 245, 245, 245),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.yellow : Colors.grey,
              ),
              onPressed: onFavoriteToggle,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symbol,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '$volume USDT',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 132, 132, 132),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPositive ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          percentage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}