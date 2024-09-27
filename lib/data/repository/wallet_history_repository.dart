import 'package:buybit/data/modal/wallet.dart';
import 'package:buybit/data/modal/wallet_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WalletHistoryRepository {
  static final WalletHistoryRepository _instance =
      WalletHistoryRepository._internal();

  factory WalletHistoryRepository() {
    return _instance;
  }

  WalletHistoryRepository._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference getCollection(String walletId) {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("User ID doesn't exist");
    }
    return _firestore.collection('users/${user.uid}/wallets/$walletId/history');
  }

  Future<void> addHistory(WalletHistory history) async {
    try {
      await getCollection(history.walletId)
          .doc(history.id)
          .set(history.toMap());
    } catch (e) {
      throw Exception("Failed to add wallet history");
    }
  }

  Future<List<WalletHistory>> fetchWalletHistory(String walletId) async {
    try {
      final querySnapshot = await getCollection(walletId).get();
      return querySnapshot.docs
          .map((doc) =>
              WalletHistory.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Failed to fetch history for wallet $walletId");
    }
  }

  Future<List<WalletHistory>> getAllWalletHistories(
      List<Wallet> wallets) async {
    List<WalletHistory> allHistories = [];
    for (var wallet in wallets) {
      final histories = await fetchWalletHistory(wallet.id);
      allHistories.addAll(histories);
    }
    return allHistories;
  }
}
