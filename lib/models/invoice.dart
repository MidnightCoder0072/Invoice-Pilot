import 'dart:convert';

import 'invoice_item.dart';

class Invoice {
  final String? id;
  final String invoiceNumber;
  final String currencyCode;
  final String client;
  final String? clientId;
  final String issueDate;
  final String dueDate;
  final double subtotal;
  final double vat;
  final double total;
  final double vatRate;
  final String taxName;
  final String status;
  final List<InvoiceItem> items;

  Invoice({
    this.id,
    required this.invoiceNumber,
    this.currencyCode = 'GBP',
    required this.client,
    this.clientId,
    required this.issueDate,
    required this.dueDate,
    required this.subtotal,
    required this.vat,
    required this.vatRate,
    this.taxName = 'VAT',
    required this.total,
    required this.status,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'invoiceNumber': invoiceNumber,
      'currencyCode': currencyCode,
      'client': client,
      'clientId': clientId,
      'issueDate': issueDate,
      'dueDate': dueDate,
      'subtotal': subtotal,
      'vat': vat,
      'vatRate': vatRate,
      'taxName': taxName,
      'total': total,
      'status': status,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  String toJson() => jsonEncode(toMap());

  factory Invoice.fromMap(
      Map<String, dynamic> map, {
        String? id,
      }) {
    final itemList = map['items'] as List<dynamic>? ?? [];

    return Invoice(
      id: id,
      invoiceNumber: (() {
        final value = map['invoiceNumber']?.toString() ?? '';
        final match = RegExp(r'^NEW-(\d+)$', caseSensitive: false)
            .firstMatch(value);

        if (match != null) {
          final number = int.parse(match.group(1)!);
          return 'INV-${number.toString().padLeft(4, '0')}';
        }

        return value;
      })(),
      currencyCode: map['currencyCode']?.toString() ?? 'GBP',
      client: map['client'] ?? '',
      clientId: map['clientId']?.toString(),
      issueDate: map['issueDate'] ?? '',
      dueDate: map['dueDate'] ?? '',
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
      vat: (map['vat'] as num?)?.toDouble() ?? 0,
      vatRate: (map['vatRate'] as num?)?.toDouble() ?? 20.0,
      taxName: map['taxName']?.toString() ?? 'VAT',
      total: (map['total'] as num?)?.toDouble() ?? 0,
      status: map['status'] ?? 'Pending',
      items: itemList
          .map(
            (item) => InvoiceItem.fromMap(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList(),
    );
  }

  factory Invoice.fromJson(String json) {
    return Invoice.fromMap(
      jsonDecode(json) as Map<String, dynamic>,
    );
  }
}