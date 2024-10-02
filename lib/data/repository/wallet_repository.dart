import 'package:buybit/data/modal/wallet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class WalletRepository {
  static final WalletRepository instance = WalletRepository._init();
  WalletRepository._init();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference getCollection() {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("User ID doesn't exist");
    }
    return _firestore.collection('users/${user.uid}/wallets');
  }

  String getUid() {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("User doesn't exist");
    }
    return user.uid;
  }

  Future<void> createWallet(String walletName, String currency) async {
    final newWallet = Wallet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: walletName,
      currency: currency,
      isDefault: false,
    );
    await getCollection().doc(newWallet.id).set(newWallet.toMap());
  }

  Future<List<Wallet>> getAllUserWallets() async {
    final response = await getCollection().get();
    return response.docs
        .map((doc) => Wallet.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<Wallet> getWalletById(String walletId) async {
    final docSnapshot = await getCollection().doc(walletId).get();
    if (!docSnapshot.exists) {
      throw Exception("Wallet not found");
    }
    return Wallet.fromMap(docSnapshot.data() as Map<String, dynamic>);
  }

  Future<void> setDefaultWallet(String walletId) async {
    final wallets = await getAllUserWallets();
    for (var wallet in wallets) {
      await getCollection()
          .doc(wallet.id)
          .update({'isDefault': wallet.id == walletId});
    }
  }

  Future<void> updateWalletName(String walletId, String newName) async {
    try {
      await getCollection().doc(walletId).update({'name': newName});
    } catch (e) {
      debugPrint("Failed to update wallet name: $e");
    }
  }

  Future<void> updateWalletBalance(String walletId, double amount) async {
    final walletDoc = await getCollection().doc(walletId).get();
    if (walletDoc.exists) {
      final wallet = Wallet.fromMap(walletDoc.data() as Map<String, dynamic>);
      if (wallet.balance >= amount) {
        wallet.balance -= amount;

        await getCollection().doc(walletId).update(wallet.toMap());
      } else {
        throw Exception('not available balance for this order.');
      }
    }
  }

  Future<void> topUpWallet(String walletId, double amount) async {
    final walletDoc = await getCollection().doc(walletId).get();
    if (walletDoc.exists) {
      final wallet = Wallet.fromMap(walletDoc.data() as Map<String, dynamic>);
      wallet.balance += amount;

      await getCollection().doc(walletId).update(wallet.toMap());
    }
  }

  Future<void> withdrawWallet(String walletId, double amount) async {
    final walletDoc = await getCollection().doc(walletId).get();
    if (walletDoc.exists) {
      final wallet = Wallet.fromMap(walletDoc.data() as Map<String, dynamic>);
      if (amount <= wallet.balance) {
        wallet.balance -= amount;
        await getCollection().doc(walletId).update(wallet.toMap());
      } else {
        throw Exception('Insufficient balance for withdrawal.');
      }
    }
  }
}
