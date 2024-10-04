import 'dart:convert';
import 'package:buybit/data/modal/coin.dart';
import 'package:buybit/data/modal/coin_candle_data.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:http/http.dart' as http;

class ApiService {
  final String apiUrl = 'https://api.binance.com';
  WebSocketChannel? _channel;

  Future<List<Coin>> fetchCoins() async {
    final response = await http.get(Uri.parse('$apiUrl/api/v3/ticker/24hr'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Coin.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load coins');
    }
  }

  Stream<double> getCurrentPriceStream(String symbol) async* {
    while (true) {
      final price = await getCurrentPrice(symbol);
      yield price;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Stream<List<Coin>> streamRealTimePrices() {
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://stream.binance.com:9443/ws/!ticker@arr'),
    );
    return _channel!.stream.map((data) {
      List<dynamic> coinDataList = json.decode(data);
      return coinDataList.map((json) => Coin.fromWebSocketJson(json)).toList();
    });
  }

  Future<double> getCurrentPrice(String symbol) async {
    final response =
        await http.get(Uri.parse('$apiUrl/api/v3/ticker/price?symbol=$symbol'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return double.parse(data['price']);
    } else {
      throw Exception('Failed to load current price');
    }
  }

  void closeWebSocket() {
    _channel?.sink.close(status.normalClosure);
  }

  Future<Coin> fetchCoinDetails(String coinId) async {
    final response = await http.get(Uri.parse('$apiUrl/api/v3/exchangeInfo'));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var coinData =
          data['symbols'].firstWhere((symbol) => symbol['symbol'] == coinId);
      return Coin.fromJson(coinData);
    } else {
      throw Exception('Failed to load coin details');
    }
  }

  Future<List<CandleData>> getCandlestickData(
      String symbol, String interval) async {
    final String url =
        '$apiUrl/api/v3/klines?symbol=$symbol&interval=$interval&limit=1000';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map<CandleData>((item) {
        return CandleData(
          time: DateTime.fromMillisecondsSinceEpoch(item[0]),
          open: double.parse(item[1]),
          high: double.parse(item[2]),
          low: double.parse(item[3]),
          close: double.parse(item[4]),
        );
      }).toList();
    } else {
      throw Exception('Failed to load candlestick data');
    }
  }
}
