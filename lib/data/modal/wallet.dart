class Wallet {
  String id;
  String name;
  String currency;
  double balance;
  bool isDefault;

  Wallet({
    required this.id,
    required this.name,
    required this.currency,
    this.balance = 0.0,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'currency': currency,
      'balance': balance,
      'isDefault': isDefault,
    };
  }

  static Wallet fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'],
      name: map['name'],
      currency: map['currency'],
      balance: map['balance'],
      isDefault: map['isDefault'] ?? false,
    );
  }
}
