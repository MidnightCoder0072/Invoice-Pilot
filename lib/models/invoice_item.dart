import 'dart:convert';

class InvoiceItem {
  final String description;
  final double amount;

  InvoiceItem({
    required this.description,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'amount': amount,
    };
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      description: map['description'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
    );
  }

  factory InvoiceItem.fromJson(String json) {
    return InvoiceItem.fromMap(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }
}