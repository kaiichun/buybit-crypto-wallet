import 'package:buybit/data/modal/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserRepo {
  CollectionReference<BuyBitUser> getUserCollRef() {
    return FirebaseFirestore.instance.collection('users').withConverter<BuyBitUser>(
      fromFirestore: (snapshot, _) => BuyBitUser.fromMap(snapshot.data()!),
      toFirestore: (user, _) => user.toMap(),
    );
  }

  String getUid() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User is not logged in");
    }
    return user.uid;
  }

  Future<void> createUser(BuyBitUser user) async {
    try {
      await getUserCollRef().doc(getUid()).set(user);
      debugPrint("User successfully created");
    } catch (e) {
      debugPrint("UserRepo => Error creating user: $e");
      rethrow;
    }
  }

  Future<BuyBitUser?> getUser() async {
    try {
      final DocumentSnapshot<BuyBitUser> doc = await getUserCollRef().doc(getUid()).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      debugPrint("UserRepo => Error getting user: $e");
    }
    return null; 
  }

  Stream<BuyBitUser?> get BuyBitUserChanges {
    return FirebaseAuth.instance.authStateChanges().asyncMap((User? firebaseUser) async {
      if (firebaseUser == null) return null; 
      try {
        final DocumentSnapshot<BuyBitUser> userDoc = await getUserCollRef().doc(firebaseUser.uid).get();
        return userDoc.exists ? userDoc.data() : null;
      } catch (e) {
        debugPrint("UserRepo => Error fetching user: $e");
        return null;
      }
    });
  }

  Future<BuyBitUser?> getUserById(String id) async {
    try {
      final DocumentSnapshot<BuyBitUser> doc = await getUserCollRef().doc(id).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      debugPrint("UserRepo => Error fetching user by ID: $e");
    }
    return null;
  }
}
