import 'package:buybit/data/api/api_service.dart';
import 'package:buybit/data/modal/coin.dart';
import 'package:buybit/data/provider/favorite_coin_provider.dart';
import 'package:buybit/data/provider/wallet_provider.dart';
import 'package:buybit/screens/market_coin_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late WalletProvider walletProvider;
  List<Coin> _favoriteCoins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    _loadWalletsTotalBalance();
    _loadFavoriteCoins();
  }

  Future<void> _loadWalletsTotalBalance() async {
    await walletProvider.fetchWallets();
  }

  void _loadFavoriteCoins() {
    setState(() {
      _isLoading = true;
    });

    _apiService.streamRealTimePrices().listen((coinList) {
      final favoriteIds =
          Provider.of<FavoriteCoinProvider>(context, listen: false).favoriteIds;

      setState(() {
        _favoriteCoins = coinList
            .where((coin) => favoriteIds.contains(coin.symbol))
            .toList();
        _isLoading = false;
      });
    });
  }

  String formatBalance(double balance) {
    return balance < 0 ? balance.toString() : balance.toStringAsFixed(2);
  }

  String formatPrice(double price) {
    return price < 0
        ? '\$${price.toString()}'
        : '\$${price.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 58, 166, 254),
        title: const Row(
          children: [
            Icon(
              Icons.currency_bitcoin,
              color: Color.fromARGB(255, 41, 41, 41),
            ),
            SizedBox(width: 4),
            Text(
              'BuyBit',
              style: TextStyle(
                color: Color.fromARGB(255, 41, 41, 41),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14.0, 12.0, 14.0, 0.0),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Balance (USD)',
                          style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 2),
                      Consumer<WalletProvider>(
                        builder: (context, walletProvider, child) {
                          final isWalletsEmpty = walletProvider.wallets.isEmpty;
                          final totalBalance =
                              walletProvider.calculateTotalBalance();

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isWalletsEmpty
                                    ? "0.00"
                                    : formatBalance(totalBalance),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 18.0),
              child: Text(
                'Favorite Coins',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const Center(
                    child: Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 100),
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text(
                            "Favorite coins is loading",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                : _favoriteCoins.isEmpty
                    ? const Center(
                        child: Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "No favorite coins",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ))
                    : Consumer<FavoriteCoinProvider>(
                        builder: (context, favoriteProvider, child) {
                          return ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _favoriteCoins.length,
                            itemBuilder: (context, index) {
                              final coin = _favoriteCoins[index];
                              final isFavorite =
                                  favoriteProvider.isFavorite(coin);
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          MarketCoinDetailScreen(
                                              coinId: coin.symbol),
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
          ],
        ),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
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
