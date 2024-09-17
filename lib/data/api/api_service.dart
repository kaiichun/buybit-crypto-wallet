import 'dart:convert';
import 'package:buybit/data/modal/coin.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiUrl = 'https://api.coingecko.com/api/v3';

  Future<List<Coin>> fetchCoins() async {
    final response =
        await http.get(Uri.parse('$apiUrl/coins/markets?vs_currency=usd'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Coin.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load coins');
    }
  }
}
