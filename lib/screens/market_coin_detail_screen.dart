import 'package:buybit/data/api/api_service.dart';
import 'package:buybit/data/modal/coin_order.dart';
import 'package:buybit/data/modal/coin_candle_data.dart';
import 'package:buybit/data/modal/wallet.dart';
import 'package:buybit/data/provider/wallet_provider.dart';
import 'package:buybit/data/repository/wallet_order_coin_repository.dart';
import 'package:buybit/data/repository/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';

class MarketCoinDetailScreen extends StatefulWidget {
  final String coinId;

  const MarketCoinDetailScreen({super.key, required this.coinId});

  @override
  _MarketCoinDetailScreenState createState() => _MarketCoinDetailScreenState();
}

class _MarketCoinDetailScreenState extends State<MarketCoinDetailScreen> {
  late ApiService _apiService;
  late List<CandleData> _candlestickData;
  late WalletProvider walletProvider;
  final WalletRepository walletRepo = WalletRepository.instance;
  List<Wallet> wallets = [];
  Wallet? defaultWallet;
  double lotSize = 0.01;
  double? lastKnownPrice;
  double _currentPrice = 0.0;
  bool _isPriceChanger = true;
  late Timer _timer;
  String _selectedTimeFrame = '1 Min';

  final Map<String, int> _timeFrameOptions = {
    '1 Min': 1,
    '5 Min': 5,
    '15 Min': 15,
    '30 Min': 30,
    '1 Hour': 60,
    '4 Hours': 240,
  };

  void _changeTimeFrame(String newTimeFrame) {
    setState(() {
      _selectedTimeFrame = newTimeFrame;
    });
  }

  bool enableSLTP = false;
  double? stopLoss;
  double? takeProfit;
  TextEditingController stopLossController = TextEditingController();
  TextEditingController takeProfitController = TextEditingController();

  final _zoomPanBehavior = ZoomPanBehavior(
    enablePanning: true,
    enableDoubleTapZooming: true,
    enablePinching: true,
    zoomMode: ZoomMode.x,
    enableMouseWheelZooming: true,
  );

  @override
  void initState() {
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    super.initState();
    _apiService = ApiService();
    _candlestickData = [];
    _fetchCandlestickData();
    _loadWallets();
    _timer = Timer.periodic(
        const Duration(seconds: 30), (Timer t) => _fetchCandlestickData());

    _apiService.streamRealTimePrices().listen((priceUpdateList) {
      for (var priceUpdate in priceUpdateList) {
        if (priceUpdate.symbol == widget.coinId) {
          setState(() {
            _isPriceChanger = priceUpdate.lastPrice >= _currentPrice;
            _currentPrice = priceUpdate.lastPrice;
            lastKnownPrice = priceUpdate.lastPrice;
          });
        }
      }
    });
  }

  Future<void> _loadWallets() async {
    await walletProvider.fetchWallets();
    setState(() {
      wallets = walletProvider.wallets;
      defaultWallet = wallets.isNotEmpty ? wallets.first : null;
    });
  }

  void _increaseLotSize() {
    setState(() {
      if (lotSize < 100) lotSize += 0.01;
    });
  }

  void _decreaseLotSize() {
    setState(() {
      if (lotSize > 0.01) lotSize -= 0.01;
    });
  }

  void _swapSLTP() {
    setState(() {
      double? temp = stopLoss;
      stopLoss = takeProfit;
      takeProfit = temp;

      stopLossController.text = stopLoss?.toStringAsFixed(4) ?? '';
      takeProfitController.text = takeProfit?.toStringAsFixed(4) ?? '';
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _fetchCandlestickData() async {
    try {
      List<CandleData> newData =
          await _apiService.getCandlestickData(widget.coinId, '1m');
      setState(() {
        _candlestickData = newData;
      });
    } catch (e) {
      debugPrint('Error fetching candlestick data');
    }
  }

  void _sellCrypto(String walletId) async {
    try {
      if (lastKnownPrice == null) throw "Price not available";

      await walletRepo.updateWalletBalance(walletId, lotSize);

      final CoinOrder coinOrder = CoinOrder(
        id: UniqueKey().toString(),
        walletId: walletId,
        symbol: widget.coinId,
        type: 'Sell/Short',
        takeProfit: takeProfit,
        stopLoss: stopLoss,
        amount: lotSize,
        price: lastKnownPrice!,
        status: 'open',
        createdAt: DateTime.now(),
      );

      await CoinOrderRepository().placeOrder(coinOrder);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order')),
      );
    } finally {
      _loadWallets();
    }
  }

  void _buyCrypto(String walletId) async {
    try {
      if (lastKnownPrice == null) throw "Price not available";

      await walletRepo.updateWalletBalance(walletId, lotSize);

      final CoinOrder coinOrder = CoinOrder(
        id: UniqueKey().toString(),
        walletId: walletId,
        symbol: widget.coinId,
        type: 'Buy/Long',
        takeProfit: takeProfit,
        stopLoss: stopLoss,
        amount: lotSize,
        price: lastKnownPrice!,
        status: 'open',
        createdAt: DateTime.now(),
      );

      await CoinOrderRepository().placeOrder(coinOrder);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order')),
      );
    } finally {
      _loadWallets();
    }
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
            Text(
              'Trade',
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
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.coinId,
                        style: const TextStyle(
                            color: Colors.black38,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    Text(_currentPrice.toStringAsFixed(2),
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color:
                                _isPriceChanger ? Colors.green : Colors.red)),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      value: _selectedTimeFrame,
                      elevation: 16,
                      style: const TextStyle(color: Colors.black),
                      underline: Container(
                        height: 2,
                        color: Colors.blueAccent,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          _changeTimeFrame(newValue);
                        }
                      },
                      items: _timeFrameOptions.keys
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ],
            ),
          ),
          _candlestickData.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: SfCartesianChart(
                    primaryXAxis: DateTimeAxis(
                      autoScrollingDelta:
                          _timeFrameOptions[_selectedTimeFrame]!,
                      autoScrollingMode: AutoScrollingMode.end,
                    ),
                    primaryYAxis: NumericAxis(
                      plotBands: [
                        PlotBand(
                          isVisible: true,
                          start: _currentPrice,
                          end: _currentPrice,
                          borderWidth: 1,
                          borderColor:
                              _isPriceChanger ? Colors.green : Colors.red,
                          dashArray: const [112, 3],
                          text: _currentPrice.toStringAsFixed(2),
                          textStyle: TextStyle(
                            color: _isPriceChanger ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAngle: 0,
                          verticalTextAlignment: TextAnchor.start,
                          horizontalTextAlignment: TextAnchor.start,
                        ),
                      ],
                    ),
                    series: <CandleSeries<CandleData, DateTime>>[
                      CandleSeries<CandleData, DateTime>(
                        dataSource: _candlestickData,
                        xValueMapper: (CandleData data, _) => data.time,
                        openValueMapper: (CandleData data, _) => data.open,
                        highValueMapper: (CandleData data, _) => data.high,
                        lowValueMapper: (CandleData data, _) => data.low,
                        closeValueMapper: (CandleData data, _) => data.close,
                        bearColor: Colors.redAccent,
                        bullColor: Colors.greenAccent,
                        animationDuration: 0,
                      ),
                    ],
                    tooltipBehavior: TooltipBehavior(enable: true),
                    zoomPanBehavior: _zoomPanBehavior,
                  ),
                ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _showBuySelectionDialog(),
                  child: const Text('Buy'),
                ),
                IconButton(
                    onPressed: _increaseLotSize, icon: const Icon(Icons.add)),
                GestureDetector(
                  onTap: _enterLotSize,
                  child: Column(
                    children: [
                      const Text('Lot Size', style: TextStyle(fontSize: 8)),
                      Text(lotSize.toStringAsFixed(2),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: _decreaseLotSize,
                    icon: const Icon(Icons.remove)),
                ElevatedButton(
                  onPressed: () => _showSellSelectionDialog(),
                  child: const Text('Sell'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: enableSLTP,
                      onChanged: (value) {
                        setState(() {
                          enableSLTP = value ?? false;

                          if (enableSLTP && lastKnownPrice != null) {
                            double pipValue = 0.0001;
                            double pipDifference = 100 * pipValue;
                            stopLoss = lastKnownPrice! - pipDifference;
                            takeProfit = lastKnownPrice! + pipDifference;
                          } else {
                            stopLoss = null;
                            takeProfit = null;
                          }
                          stopLossController.text =
                              stopLoss?.toStringAsFixed(4) ?? '';
                          takeProfitController.text =
                              takeProfit?.toStringAsFixed(4) ?? '';
                        });
                      },
                    ),
                    const Text('SL/TP'),
                  ],
                ),
                if (enableSLTP)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: stopLossController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Stop Loss',
                            labelStyle: TextStyle(color: Colors.red),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              stopLoss = double.tryParse(value);
                            });
                          },
                        ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: takeProfitController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Take Profit',
                            labelStyle: TextStyle(color: Colors.green),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              takeProfit = double.tryParse(value);
                            });
                          },
                        ),

                        // Swap button
                        ElevatedButton(
                          onPressed: _swapSLTP,
                          child: const Text('Swap SL/TP'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _enterLotSize() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Lot Size'),
          content: TextFormField(
            initialValue: lotSize.toString(),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                lotSize = double.tryParse(value) ?? lotSize;
              });
            },
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Save')),
          ],
        );
      },
    );
  }

  void _showBuySelectionDialog() {
    Wallet? selectedWallet = defaultWallet;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Wallet to Trade'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: 300,
                height: 400,
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: Column(
                      children: walletProvider.wallets.map((wallet) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedWallet = wallet;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6.0),
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedWallet == wallet
                                    ? Colors.green
                                    : Colors.grey,
                                width: selectedWallet == wallet ? 3 : 0,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ListTile(
                              title: Text(wallet.name),
                              subtitle: Text(
                                'Balance (${wallet.currency}): ${formatBalance(wallet.balance)}',
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Confirm'),
              onPressed: selectedWallet != null
                  ? () {
                      if (selectedWallet != null) {
                        _buyCrypto(
                          selectedWallet!.id,
                        );
                      }
                      Navigator.of(context).pop();
                    }
                  : null,
              style: TextButton.styleFrom(
                backgroundColor:
                    selectedWallet != null ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSellSelectionDialog() {
    Wallet? selectedWallet = defaultWallet;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Wallet to Trade'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: 300,
                height: 400,
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: Column(
                      children: walletProvider.wallets.map((wallet) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedWallet = wallet;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6.0),
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedWallet == wallet
                                    ? Colors.green
                                    : Colors.grey,
                                width: selectedWallet == wallet ? 3 : 0,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ListTile(
                              title: Text(wallet.name),
                              subtitle: Text(
                                'Balance (${wallet.currency}): ${formatBalance(wallet.balance)}',
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Confirm'),
              onPressed: selectedWallet != null
                  ? () {
                      if (selectedWallet != null) {
                        _sellCrypto(
                          selectedWallet!.id,
                        );
                      }
                      Navigator.of(context).pop();
                    }
                  : null,
              style: TextButton.styleFrom(
                backgroundColor:
                    selectedWallet != null ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        );
      },
    );
  }
}
