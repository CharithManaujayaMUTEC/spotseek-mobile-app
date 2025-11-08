import 'package:spotseeker_app/models/invoice_models.dart';

/// Abstract repository for invoice-related operations.
abstract class InvoiceRepository {
  /// Fetch a list of invoices for a profile or event.
  Future<List<InvoiceData>> fetchInvoices({String? profileId, String? status});

  /// Fetch a single invoice by invoice number or id.
  Future<InvoiceData> fetchInvoice(String invoiceNumber);

  /// Create or generate an invoice (API-backed implementation will handle creation).
  Future<InvoiceData> createInvoice(Map<String, dynamic> payload);
}
