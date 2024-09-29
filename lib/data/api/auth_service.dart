import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  AuthService() {
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? getCurrentUser() {
    return _user;
  }

  bool isLoggedIn() {
    return _user != null;
  }

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      notifyListeners();
      return _user;
    } catch (e) {
      debugPrint('Error creating user');
      return null;
    }
  }

  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      notifyListeners();
      return _user;
    } catch (e) {
      debugPrint('Error logging in');
      return null;
    }
  }

  void logout() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

  String? getUid() {
    return _user?.uid;
  }
}
