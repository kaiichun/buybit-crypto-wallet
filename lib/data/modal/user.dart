class BuyBitUser {
  final String id;
  final String name;
  final String email;
  BuyBitUser({
    required this.id,
    required this.name,
    required this.email,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  factory BuyBitUser.fromMap(Map<String, dynamic> map) {
    return BuyBitUser(
      id: map['id'],
      name: map['name'],
      email: map['email'],
    );
  }
}
