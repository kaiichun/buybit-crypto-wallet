import 'package:buybit/data/modal/coin_order.dart';
import 'package:buybit/data/modal/wallet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoinOrderRepository {
  static final CoinOrderRepository _instance = CoinOrderRepository._internal();

  factory CoinOrderRepository() {
    return _instance;
  }

  CoinOrderRepository._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference getCollection(String walletId) {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("User ID doesn't exist");
    }
    return _firestore.collection('users/${user.uid}/wallets/$walletId/orders');
  }

  Future<void> placeOrder(CoinOrder order) async {
    await getCollection(order.walletId).doc(order.id).set(order.toMap());
  }

  Future<List<CoinOrder>> fetchWalletOrders(String walletId) async {
    final querySnapshot = await getCollection(walletId).get();
    return querySnapshot.docs
        .map((doc) => CoinOrder.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<CoinOrder>> getAllWalletsOrders(List<Wallet> wallets) async {
    List<CoinOrder> allOrders = [];

    for (var wallet in wallets) {
      final orders = await fetchWalletOrders(wallet.id);
      allOrders.addAll(orders);
    }

    return allOrders;
  }

  Future<void> updateOrderStatus(
      String walletId, String orderId, String newStatus) async {
    try {
      DocumentReference orderDoc = getCollection(walletId).doc(orderId);
      await orderDoc.update({'status': newStatus});
    } catch (e) {
      throw Exception("Failed to update order status");
    }
  }

  Future<List<CoinOrder>> getActiveOrders(List<Wallet> wallets) async {
    List<CoinOrder> allActiveOrders = [];

    for (var wallet in wallets) {
      final orders = await fetchWalletOrders(wallet.id);

      final activeOrders =
          orders.where((order) => order.status != 'closed').toList();

      allActiveOrders.addAll(activeOrders);
    }

    return allActiveOrders;
  }

  Future<void> closeOrder(String walletId, String orderId) async {
    try {
      DocumentReference orderDoc = getCollection(walletId).doc(orderId);
      await orderDoc.update({'status': 'closed'});
    } catch (e) {
      throw Exception("Failed to close order");
    }
  }
}
