import 'package:flutter/material.dart';
import 'package:buybit/data/modal/coin.dart';
import 'package:buybit/data/repository/favorite_coin_repository.dart';

class FavoriteCoinProvider extends ChangeNotifier {
  final FavoriteCoinRepository _repository = FavoriteCoinRepository.instance;
  List<String> _favoriteIds = []; 
  List<String> get favoriteIds => _favoriteIds;

  Future<void> loadFavorites() async {
    _favoriteIds = await _repository.getAllUserFavoriteIds();
    notifyListeners();
  }

  bool isFavorite(Coin coin) {
    return _favoriteIds.contains(coin.symbol);
  }

  Future<void> toggleFavorite(Coin coin) async {
    await _repository.toggleFavorite(coin);
    await loadFavorites();
  }
}
