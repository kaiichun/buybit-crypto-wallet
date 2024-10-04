import 'package:buybit/data/modal/coin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteCoinRepository {
  static final FavoriteCoinRepository instance = FavoriteCoinRepository._init();
  FavoriteCoinRepository._init();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference getCollection() {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("User doesn't exist");
    }
    return _firestore.collection('users/${user.uid}/favorites');
  }
  String getUid() {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("User doesn't exist");
    }
    return user.uid;
  }
  Future<void> toggleFavorite(Coin coin) async {
    final collection = getCollection();
    final doc = collection.doc(coin.symbol);
    final docSnapshot = await doc.get();
    if (docSnapshot.exists) {
      await doc.delete();
    } else {
      await doc.set(
          {'symbol': coin.symbol}); 
    }
  }
  Future<List<String>> getAllUserFavoriteIds() async {
    final response = await getCollection().get();
    return response.docs
        .map((doc) => doc.id)
        .toList(); 
  }
}