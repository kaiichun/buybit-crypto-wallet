class Wallet {
  String id;
  String name;
  String currency;
  double balance;
  double availableBalance;
  bool isDefault;

  Wallet({
    required this.id,
    required this.name,
    required this.currency,
    this.availableBalance = 0.0,
    this.balance = 0.0,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'currency': currency,
      'balance': balance,
      'availableBalance': availableBalance,
      'isDefault': isDefault,
    };
  }

  static Wallet fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'],
      name: map['name'],
      currency: map['currency'],
      balance: map['balance'],
      availableBalance: map['availableBalance'] ?? 0.0,
      isDefault: map['isDefault'] ?? false,
    );
  }
}
