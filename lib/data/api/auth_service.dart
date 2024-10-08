import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Send verification email
      await userCredential.user?.sendEmailVerification();

      return userCredential.user;
    } catch (e) {
      debugPrint('Error creating user: $e');
      return null;
    }
  }

  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      debugPrint('Error logging in: $e');
      return null;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
    }
  }

  Future<bool> verifyCurrentPassword(String currentPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        await user.reauthenticateWithCredential(credential);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error verifying current password: $e');
      return false;
    }
  }


  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPassword,
        );

        await user.reauthenticateWithCredential(credential);

        await user.updatePassword(newPassword);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error changing password: $e');
      return false;
    }
  }

  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  void logout() {
    _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  String? getUid() {
    return _auth.currentUser?.uid;
  }
}
