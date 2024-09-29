import 'package:buybit/data/modal/wallet.dart';
import 'package:buybit/data/repository/wallet_repository.dart';
import 'package:flutter/material.dart';

class WalletProvider with ChangeNotifier {
  final WalletRepository _walletRepository = WalletRepository.instance;

  List<Wallet> _wallets = [];
  String? _defaultWalletId;

  List<Wallet> get wallets => _wallets;

  String? get defaultWalletId => _defaultWalletId;
  Wallet? _defaultWallet;
  Wallet? get defaultWallet => _defaultWallet;

  double calculateTotalBalance() {
    return wallets.fold(0, (sum, wallet) => sum + wallet.balance);
  }

  Future<void> fetchWallets() async {
    notifyListeners();
    try {
      _wallets = await _walletRepository.getAllUserWallets();
      _defaultWalletId = _wallets
          .firstWhere((wallet) => wallet.isDefault,
              orElse: () =>
                  Wallet(id: '', name: '', currency: '', isDefault: false))
          .id;
    } catch (e) {
      debugPrint("Failed to fetch wallets");
    } finally {
      notifyListeners();
    }
  }

  Future<void> setDefaultWallet(String walletId) async {
    notifyListeners();
    try {
      await _walletRepository.setDefaultWallet(walletId);
      await fetchWallets();
    } catch (e) {
      debugPrint("Failed to set default wallet");
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchDefaultWallet() async {
    notifyListeners();
    try {
      if (_defaultWalletId != null) {
        _defaultWallet = _wallets.firstWhere(
          (wallet) => wallet.id == _defaultWalletId,
          orElse: () =>
              Wallet(id: '', name: '', currency: '', isDefault: false),
        );
      } else {
        await fetchWallets();
        if (_defaultWalletId != null) {
          _defaultWallet = _wallets.firstWhere(
            (wallet) => wallet.id == _defaultWalletId,
            orElse: () =>
                Wallet(id: '', name: '', currency: '', isDefault: false),
          );
        }
      }
    } catch (e) {
      debugPrint("Failed to fetch default wallet");
    } finally {
      notifyListeners();
    }
  }
}
