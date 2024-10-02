import 'package:buybit/data/api/api_service.dart';
import 'package:buybit/data/modal/coin.dart';
import 'package:buybit/data/modal/coin_order.dart';
import 'package:buybit/data/modal/wallet_history.dart';
import 'package:buybit/data/provider/wallet_provider.dart';
import 'package:buybit/data/repository/wallet_history_repository.dart';
import 'package:buybit/data/repository/wallet_order_coin_repository.dart';
import 'package:buybit/data/repository/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});
  @override
  _OrderScreenState createState() => _OrderScreenState();
}
class _OrderScreenState extends State<OrderScreen> {
  List<CoinOrder> activeOrders = [];
  final CoinOrderRepository coinOrderRepo = CoinOrderRepository();
  final WalletRepository walletRepo = WalletRepository.instance;
  bool isLoading = true; 
  @override
  void initState() {
    super.initState();
    _loadActiveOrders();
    _listenToPriceUpdates();
  }
  Future<void> _loadActiveOrders() async {
    try {
      WalletProvider walletProvider =
          Provider.of<WalletProvider>(context, listen: false);
      await walletProvider.fetchWallets();
      List<CoinOrder> orders =
          await coinOrderRepo.getActiveOrders(walletProvider.wallets);
      setState(() {
        activeOrders = orders;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading active orders: $e');
    }
  }
  void _listenToPriceUpdates() {
    ApiService().streamRealTimePrices().listen((coins) {
      _checkOrderConditions(coins);
    });
  }
  void _checkOrderConditions(List<Coin> coins) {
    for (var order in activeOrders) {
      final coinPrice = coins.firstWhere(
        (coin) => coin.symbol == order.symbol,
        orElse: () => Coin(
          symbol: order.symbol,
          lastPrice: 0,
          volume: 0,
          priceChangePercentage24h: 0.0,
        ),
      );
      order.currentPrice = coinPrice.lastPrice;
      if (order.type == 'Buy') {
        if ((order.takeProfit != null &&
                order.currentPrice >= order.takeProfit!) ||
            (order.stopLoss != null && order.currentPrice <= order.stopLoss!)) {
          _closeOrder(order, order.currentPrice);
        }
      } else if (order.type == 'Sell') {
        if ((order.takeProfit != null &&
                order.currentPrice <= order.takeProfit!) ||
            (order.stopLoss != null && order.currentPrice >= order.stopLoss!)) {
          _closeOrder(order, order.currentPrice);
        }
      }
    }
    setState(() {});
  }
  Future<void> _closeOrder(CoinOrder order, double currentPrice,
      {bool isManualClose = false}) async {
    try {
      double floatingGainOrLoss;
      if (order.type == 'Sell') {
        floatingGainOrLoss = (currentPrice - order.price) * order.amount;
      } else {
        floatingGainOrLoss = (order.price - currentPrice) * order.amount;
      }
      double profitOrLoss = floatingGainOrLoss;
      String action = '';
      if (order.type == 'buy') {
        if (order.takeProfit != null && currentPrice >= order.takeProfit!) {
          action = 'takeprofit';
        } else if (order.stopLoss != null && currentPrice <= order.stopLoss!) {
          action = 'stoploss';
        }
      } else if (order.type == 'Sell') {
        if (order.takeProfit != null && currentPrice <= order.takeProfit!) {
          action = 'takeprofit';
        } else if (order.stopLoss != null && currentPrice >= order.stopLoss!) {
          action = 'stoploss';
        }
      }
      await coinOrderRepo.closeOrder(order.walletId, order.id);
      if (profitOrLoss > 0) {
        action = 'profit';
        await walletRepo.topUpWallet(order.walletId, profitOrLoss);
      } else {
        action = 'loss';
        await walletRepo.withdrawWallet(order.walletId, profitOrLoss.abs()); 
      }
      final WalletHistory history = WalletHistory(
        id: UniqueKey().toString(),
        walletId: order.walletId,
        action: action,
        amount: profitOrLoss.abs(),
        date: DateTime.now(),
      );
      await WalletHistoryRepository().addHistory(history);
      await _loadActiveOrders();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order closed successfully.')));
    } catch (e) {
      debugPrint('Error closing order: $e');
    }
  }
  String formatPrice(double price) {
    if (price < 1) {
      return price.toString();
    } else {
      return price.toStringAsFixed(2);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 58, 166, 254),
        title: const Row(
          children: [
            Icon(
              Icons.price_change,
              color: Color.fromARGB(255, 41, 41, 41),
            ),
            SizedBox(width: 8),
            Text(
              'Orders',
              style: TextStyle(
                color: Color.fromARGB(255, 41, 41, 41),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : activeOrders.isEmpty
              ? const Center(child: Text('No active orders'))
              : ListView.builder(
                  itemCount: activeOrders.length,
                  itemBuilder: (context, index) {
                    final order = activeOrders[index];
                    double floatingGainOrLoss = order.type == 'Buy'
                        ? (order.currentPrice - order.price) * order.amount
                        : (order.price - order.currentPrice) * order.amount;
                    return ListTile(
                      title: Text('${order.symbol} \'${order.type}\''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Entry: ${formatPrice(order.price)}',
                                style: const TextStyle(
                                  fontSize: 12.0,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Current: ${formatPrice(order.currentPrice)}',
                                style: const TextStyle(
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                'TakeProfit: ${order.takeProfit ?? 'N/A'}',
                                style: const TextStyle(
                                  fontSize: 12.0,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'StopLoss: ${order.stopLoss ?? 'N/A'}',
                                style: const TextStyle(
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                'Profit/Loss: ',
                                style: TextStyle(
                                  fontSize: 12.0,
                                ),
                              ),
                              Text(
                                '${floatingGainOrLoss >= 0 ? '+' : ''}${floatingGainOrLoss.toStringAsFixed(4)}',
                                style: TextStyle(
                                  color: floatingGainOrLoss >= 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _closeOrder(order, order.currentPrice),
                        child: const Text('Close'),
                      ),
                    );
                  },
                ),
    );
  }
}