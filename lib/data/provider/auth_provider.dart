import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  String get userName => _user?.displayName ?? 'User';  // Display user name or 'User' if null

  String get userEmail => _user?.email ?? 'Unknown Email';  // Display email or 'Unknown Email'

  // Load the current user from FirebaseAuth
  Future<void> loadCurrentUser() async {
    try {
      _user = FirebaseAuth.instance.currentUser;
      if (_user != null) {
        print('User loaded: ${_user?.displayName}, ${_user?.email}');
      } else {
        print('No user is currently signed in.');
      }
      notifyListeners();  // Notify UI about the change
    } catch (e) {
      print('Error loading user: $e');
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> updateUserName(String newUserName) async {
    try {
      await _user?.updateDisplayName(newUserName);
      await _user?.reload();
      _user = FirebaseAuth.instance.currentUser;
      notifyListeners();  // Update UI
      print('User name updated to: $newUserName');
    } catch (e) {
      print('Error updating user name: $e');
    }
  }
}
