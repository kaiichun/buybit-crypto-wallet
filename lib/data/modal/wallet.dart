import 'package:buybit/data/modal/order.dart';

class Wallet {
  final String id;
  final String name;
  final double balance;
  final List<Order> orders;

  Wallet({
    required this.id,
    required this.name,
    required this.balance,
    required this.orders,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'orders': orders.map((order) => order.toMap()).toList(),
    };
  }

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'],
      name: map['name'],
      balance: map['balance'],
      orders:
          List<Order>.from(map['orders']?.map((order) => Order.fromMap(order))),
    );
  }
}
