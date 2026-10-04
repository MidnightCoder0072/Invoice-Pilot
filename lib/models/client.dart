import 'dart:convert';

class Client {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String address;

  Client({
    this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.address = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }

  String toJson() => jsonEncode({
    'id': id,
    ...toMap(),
  });

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
    );
  }

  factory Client.fromJson(String json) {
    return Client.fromMap(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }
}