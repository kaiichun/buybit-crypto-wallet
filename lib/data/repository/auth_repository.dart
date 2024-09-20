import 'package:buybit/data/modal/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthRepository {
  static AuthRepository instance = AuthRepository._inti();
  factory AuthRepository() {
    return instance;
  }
  AuthRepository._inti();
  final _database = FirebaseFirestore.instance.collection("users");
  String getUid() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User doesn't exist");
    }
    return user.uid;
  }
  Future<void> createUser(BuyBitUser user) async {
    try {
      await _database.doc(getUid()).set(user.toMap());
    } catch (e) {
      debugPrint("AuthRepository Error creating user: $e");
      rethrow;
    }
  }
  Future<BuyBitUser?> getUser() async {
    final DocumentSnapshot doc = await _database.doc(getUid()).get();
    if (doc.exists) {
      return BuyBitUser.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
  Future<BuyBitUser?> getUserById(String id) async {
    final DocumentSnapshot doc = await _database.doc(id).get();
    if (doc.exists) {
      return BuyBitUser.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}