import 'package:buybit/data/api/api_service.dart';
import 'package:buybit/data/provider/favorite_coin_provider.dart';
import 'package:buybit/data/provider/wallet_provider.dart';
import 'package:buybit/data/service/auth_service.dart';
import 'package:buybit/screens/market_coin_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  late WalletProvider walletProvider;

  void _logout() {
    _authService.logout();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  String formatBalance(double balance) {
    return balance < 0 ? balance.toString() : balance.toStringAsFixed(2);
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Color.fromARGB(255, 41, 41, 41),
            ),
            onPressed: _logout,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 0.0),
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
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formatBalance(
                                    walletProvider.calculateTotalBalance()),
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
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
              padding: EdgeInsets.only(left: 4.0),
              child: Text(
                'Favorite Coins',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Consumer<FavoriteCoinProvider>(
              builder: (context, favoritesProvider, child) {
                final favoriteCoins = favoritesProvider.favoriteIds;
                if (favoriteCoins.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No favorite coins added yet!',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: favoriteCoins.length,
                  itemBuilder: (context, index) {
                    final coinSymbol = favoriteCoins[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.attach_money),
                        title: Text(coinSymbol),
                        subtitle: StreamBuilder<double>(
                          stream: _apiService.getCurrentPriceStream(coinSymbol),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text('Loading...');
                            } else if (snapshot.hasError) {
                              return const Text('Error fetching price');
                            } else {
                              final livePrice = snapshot.data ?? 0.0;
                              return Text('Live Price: \$${livePrice.toStringAsFixed(2)}');
                            }
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MarketCoinDetailScreen(coinId: coinSymbol),
                            ),
                          );
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
}