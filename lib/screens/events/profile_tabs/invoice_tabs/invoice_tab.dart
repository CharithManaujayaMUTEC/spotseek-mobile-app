import 'package:flutter/material.dart';
import 'package:spotseeker_app/services/invoice_repository_mock.dart';
import 'package:spotseeker_app/models/invoice_models.dart';

class InvoiceTab extends StatelessWidget {
  final InvoiceData? invoice;
  const InvoiceTab({Key? key, this.invoice}) : super(key: key);

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Onest',
          fontWeight: FontWeight.w400,
        ),
      );

  Widget _headerLabel(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
            fontFamily: 'Onest',
            fontWeight: FontWeight.w400,
          ),
        ),
      );

  Widget _cellLabel(
    String label, {
    TextAlign textAlign = TextAlign.start,
    bool all = true,
    bool left = false,
    bool right = false,
  }) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: all
              ? Border.all(color: Colors.white.withOpacity(0.10))
              : Border(
                  left: left ? BorderSide(color: Colors.white.withOpacity(0.10)) : BorderSide.none,
                  right: right ? BorderSide(color: Colors.white.withOpacity(0.10)) : BorderSide.none,
                ),
        ),
        child: Text(
          label,
          textAlign: textAlign,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'Onest',
            fontWeight: FontWeight.w400,
          ),
        ),
      );
  Widget _buildTable({
    required String title,
    required List<int> flexes,
    required List<String> headers,
    required List<List<String>> rows,
    String? footerLabel,
    String? footerValue,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: _sectionTitle(title)),
          const SizedBox(height: 12),

          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(headers.length, (i) {
                return Expanded(flex: flexes[i], child: _headerLabel(headers[i]));
              }),
            ),
          ),

          const SizedBox(height: 8),

          Column(
            children: rows.map((cells) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(cells.length, (i) {
                    final isLast = i == cells.length - 1;
                    final textAlign = isLast
                        ? TextAlign.right
                        : (i == 0 ? TextAlign.start : TextAlign.center);
                    return Expanded(
                      flex: flexes[i],
                      child: _cellLabel(cells[i], textAlign: textAlign, right: !isLast),
                    );
                  }),
                ),
              );
            }).toList(),
          ),

          if (footerLabel != null || footerValue != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    footerLabel ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Onest',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    footerValue ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Onest',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );

    Widget _buildWithData(BuildContext context, InvoiceData invoiceData) {
      String formatCurrency(num value, {bool noDecimals = false}) {
        if (noDecimals) {
          final intVal = value.toInt();
          final s = intVal.toString();
          final regex = RegExp(r"\B(?=(\d{3})+(?!\d))");
          return s.replaceAllMapped(regex, (m) => ',');
        }
        final fixed = value.toStringAsFixed(2);
        final parts = fixed.split('.');
        final intPart = parts[0];
        final regex = RegExp(r"\B(?=(\d{3})+(?!\d))");
        final formattedInt = intPart.replaceAllMapped(regex, (m) => ',');
        return '$formattedInt.${parts[1]}';
      }

      String formatDate(DateTime d) {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
      }

      final revenueTableRows = invoiceData.revenueItems
          .map((r) => [r.packageName, r.soldQuantity.toString(), formatCurrency(r.price, noDecimals: true), formatCurrency(r.total)])
          .toList();

      final promoTableRows = invoiceData.promoCodes
          .map((p) => [p.code, p.usedQuantity.toString(), p.discount, formatCurrency(p.totalDiscount)])
          .toList();

      final withdrawalTableRows = invoiceData.withdrawals.map((w) => [w.date, w.note, formatCurrency(w.amount)]).toList();

      const revenueFooterLabel = 'TOTAL REVENUE';
      final revenueFooterValue = 'LKR ${formatCurrency(invoiceData.revenueSummary.totalRevenue)}';

      const promoFooterLabel = 'TOTAL PROMO DISCOUNT';
      final promoFooterValue = 'LKR ${formatCurrency(invoiceData.promoSummary.totalPromoDiscount)}';

      const withdrawalFooterLabel = 'TOTAL WITHDRAWALS';
      final withdrawalFooterValue = 'LKR ${formatCurrency(invoiceData.withdrawalSummary.totalWithdrawals)}';

      return SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: -273,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 3345,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: const Alignment(0.50, 0.99),
                    end: const Alignment(0.50, 0.96),
                    colors: [Colors.black, Colors.black.withOpacity(0)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 69,
              top: -70,
              child: Opacity(
                opacity: 0.50,
                child: Container(
                  width: 238,
                  height: 53,
                  decoration: const ShapeDecoration(
                    color: Color(0xFF653BFF),
                    shape: OvalBorder(),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    child: Image.asset(
                      'assets/invoice_banner.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.white10,
                        child: const Center(
                          child: Text('Invoice Banner', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: SizedBox(
                            width: 133,
                            height: 60,
                            child: Image.asset(
                              'assets/old_spotseeker_logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 200,
                                color: Colors.white10,
                                child: const Center(
                                  child: Text('Invoice Banner', style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Invoice Number',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 14,
                                    fontFamily: 'Onest',
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  invoiceData.invoiceNumber,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Onest',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Invoice Date',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 14,
                                    fontFamily: 'Onest',
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  formatDate(invoiceData.invoiceDate),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Onest',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(minHeight: 64),
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white.withOpacity(0.10)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.white.withOpacity(0.10)),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Image.network(
                                  invoiceData.event.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(color: Colors.white10),
                                ),
                              ),
                              const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      invoiceData.event.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Onest',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatDate(invoiceData.event.date),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontFamily: 'Onest',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildTable(
                          title: 'Revenue Details',
                          flexes: [3, 2, 2, 3],
                          headers: ['PACKAGE', 'SOLD QTY', 'PRICE', 'TOTAL'],
                          rows: revenueTableRows,
                          footerLabel: revenueFooterLabel,
                          footerValue: revenueFooterValue,
                        ),

                        const SizedBox(height: 20),

                        _buildTable(
                          title: 'Promocode Details',
                          flexes: [3, 2, 2, 3],
                          headers: ['PROMO CODE', 'USED QTY', 'DISCOUNT', 'TOTAL DIS'],
                          rows: promoTableRows,
                          footerLabel: promoFooterLabel,
                          footerValue: promoFooterValue,
                        ),

                        const SizedBox(height: 20),

                        _buildTable(
                          title: 'Withdrawals Summary',
                          flexes: [2, 4, 3],
                          headers: ['DATE', 'NOTE', 'AMOUNT'],
                          rows: withdrawalTableRows,
                          footerLabel: withdrawalFooterLabel,
                          footerValue: withdrawalFooterValue,
                        ),

                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.3),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Opacity(
                                opacity: 0.60,
                                child: Text(
                                  'Revenue Summary',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Onest',
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Sales Revenues',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    'LKR ${formatCurrency(invoiceData.revenueSummary.totalRevenue)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Promo Discounts',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    'LKR ${formatCurrency(invoiceData.promoSummary.totalPromoDiscount)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              Divider(color: Colors.white.withOpacity(0.10)),
                              const SizedBox(height: 6),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Adjusted Revenue',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    'LKR ${formatCurrency(invoiceData.financialSummary.adjustedRevenue)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Divider(color: Colors.white.withOpacity(0.10), thickness: 1.0, height:3.0),
                              Divider(color: Colors.white.withOpacity(0.10), thickness: 1.0, height: 3.0),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.3),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Financial Summary',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14,
                                  fontFamily: 'Onest',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Adjusted Revenue',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    'LKR ${formatCurrency(invoiceData.financialSummary.adjustedRevenue)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Withdrawals',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    'LKR ${formatCurrency(invoiceData.financialSummary.totalWithdrawals)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Divider(color: Colors.white.withOpacity(0.10)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Remaining Balance',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    'LKR ${formatCurrency(invoiceData.financialSummary.remainingBalance)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Spotseeker Commission',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    '${(invoiceData.financialSummary.commissionRate * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Divider(color: Colors.white.withOpacity(0.10)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Final Remaining Payout',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    'LKR ${formatCurrency(invoiceData.financialSummary.finalPayout)}',
                                    style: const TextStyle(
                                      color: Color(0xFF3AF15D),
                                      fontSize: 14,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Divider(color: Colors.white.withOpacity(0.10), thickness: 1.0, height:3.0),
                              Divider(color: Colors.white.withOpacity(0.10), thickness: 1.0, height: 3.0),
                            ],
                          ),
                        ),
                      
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Align(
                                alignment: Alignment.centerRight,
                                child: Image.asset(
                                  invoiceData.companyInfo.signatureUrl,
                                  width: 100,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 200,
                                    color: Colors.white10,
                                    child: const Center(
                                      child: Text('Sign', style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ),
                                Align(
                                alignment: Alignment.centerRight,
                                child: Opacity(
                                  opacity: 0.50,
                                  child: Text(
                                    invoiceData.companyInfo.name,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Opacity(
                                  opacity: 0.50,
                                  child: Text(
                                    invoiceData.companyInfo.registrationNumber,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Opacity(
                                  opacity: 0.50,
                                  child: Text(
                                    formatDate(invoiceData.companyInfo.signatureDate),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                  
                    ),
                  ),
                   const SizedBox(height: 18),             
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Download invoice')),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE50914),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: Text(
                          'Download Invoice',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

  Future<InvoiceData> _loadInvoiceFromAsset() async {
    final repo = MockInvoiceRepository();
    final list = await repo.fetchInvoices();
    if (list.isNotEmpty) return list.first;
    throw Exception('No invoice data in mock');
  }

  @override
  Widget build(BuildContext context) {
    if (invoice != null) {
      return _buildWithData(context, invoice!);
    }

    return FutureBuilder<InvoiceData>(
      future: _loadInvoiceFromAsset(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Unable to load invoice data'));
        }
        return _buildWithData(context, snapshot.data!);
      },
    );
  }
}