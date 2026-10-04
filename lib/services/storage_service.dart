import 'package:shared_preferences/shared_preferences.dart';

import '../models/client.dart';
import '../models/invoice.dart';

class StorageService {
  Future<void> saveClients(List<Client> clients) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      'clients',
      clients.map((client) => client.toJson()).toList(),
    );
  }

  Future<List<Client>> loadClients() async {
    final prefs = await SharedPreferences.getInstance();

    final savedClients = prefs.getStringList('clients');

    if (savedClients == null) {
      return [];
    }

    return savedClients
        .map((clientJson) => Client.fromJson(clientJson))
        .toList();
  }

  Future<void> saveInvoices(List<Invoice> invoices) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      'invoices',
      invoices.map((invoice) => invoice.toJson()).toList(),
    );
  }

  Future<List<Invoice>> loadInvoices() async {
    final prefs = await SharedPreferences.getInstance();

    final savedInvoices = prefs.getStringList('invoices');

    if (savedInvoices == null) {
      return [];
    }

    return savedInvoices
        .map((invoiceJson) => Invoice.fromJson(invoiceJson))
        .toList();
  }
}