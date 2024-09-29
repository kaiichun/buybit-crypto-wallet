import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;
  String get userName =>
      _user?.displayName ?? _user?.email ?? "Unknow UserName";

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void logout() {
    FirebaseAuth.instance.signOut();
    setUser(null);
  }
}
