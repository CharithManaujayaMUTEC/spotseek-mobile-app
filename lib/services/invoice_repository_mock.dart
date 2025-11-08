import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'invoice_repository.dart';
import 'package:spotseeker_app/models/invoice_models.dart';

class MockInvoiceRepository implements InvoiceRepository {
  final String assetPath;

  MockInvoiceRepository({this.assetPath = 'assets/mocks/invoice_sample.json'});

  Future<Map<String, dynamic>> _loadJson() async {
    final jsonStr = await rootBundle.loadString(assetPath);
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  @override
  Future<List<InvoiceData>> fetchInvoices({String? profileId, String? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final doc = await _loadJson();
    // invoice_sample.json is a single invoice object; return as a one-item list
    final invoice = InvoiceData.fromJson(doc);
    return [invoice];
  }

  @override
  Future<InvoiceData> fetchInvoice(String invoiceNumber) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final doc = await _loadJson();
    final invoice = InvoiceData.fromJson(doc);
    if (invoice.invoiceNumber == invoiceNumber) return invoice;
    throw Exception('Invoice not found in mock');
  }

  @override
  Future<InvoiceData> createInvoice(Map<String, dynamic> payload) async {
    // Mock: echo payload into a minimal InvoiceData or throw if payload incomplete.
    await Future.delayed(const Duration(milliseconds: 350));
    final doc = await _loadJson();
    return InvoiceData.fromJson(doc);
  }
}
