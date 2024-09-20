import 'package:buybit/data/modal/wallet.dart';

class BuyBitUser {
  final String id;
  final String name;
  final String email;
  final List<Wallet> wallets;
  BuyBitUser({
    required this.id,
    required this.name,
    required this.email,
    required this.wallets,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'wallets': wallets.map((wallet) => wallet.toMap()).toList(),
    };
  }
  factory BuyBitUser.fromMap(Map<String, dynamic> map) {
    return BuyBitUser(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      wallets: List<Wallet>.from(map['wallets']?.map((w) => Wallet.fromMap(w))),
    );
  }
}