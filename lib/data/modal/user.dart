import 'package:buybit/data/modal/wallet.dart';

class User {
  final String id;
  final String name;
    final String email;
  final int phoneNumber;
  final List<Wallet> wallets;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.wallets,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email, 
      'phone': phoneNumber,
      'wallets': wallets.map((wallet) => wallet.toMap()).toList(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],  
      phoneNumber: map['phoneNumber'],
      wallets: List<Wallet>.from(map['wallets']?.map((w) => Wallet.fromMap(w))),
    );
  }
}