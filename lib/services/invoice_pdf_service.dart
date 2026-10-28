import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InvoicePdfService {
  static Future<Uint8List> generateInvoicePdf({
    required double vatRate,
    required String taxName,
    required String invoiceNumber,
    required String clientName,
    String clientEmail = '',
    String clientPhone = '',
    String clientAddress = '',
    String businessName = '',
    String businessEmail = '',
    String businessPhone = '',
    String businessAddress = '',
    String businessWebsite = '',
    String businessTaxNumber = '',
    required String issueDate,
    required String dueDate,
    required String status,
    required double subtotal,
    required double vat,
    required double total,
    required List<Map<String, dynamic>> items,
    required String currencySymbol,
    String customPaymentMethodName = '',
    String customPaymentLink = '',
    String stripePaymentLink = '',
    String paypalPaymentLink = '',
    String bankAccountName = '',
    String bankName = '',
    String bankAccountNumber = '',
    String bankRouting = '',
    String bankPaymentInstructions = '',
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(
          28,
          20,
          28,
          25,
        ),
        header: (context) {
          return pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: PdfColors.blue200, width: 1),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (businessName.trim().isNotEmpty)
                            pw.Text(
                              businessName.trim(),
                              style: pw.TextStyle(
                                fontSize: 16,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blue900,
                              ),
                            ),
                          if (businessAddress.trim().isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              businessAddress.trim(),
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                          if (businessEmail.trim().isNotEmpty) ...[
                            pw.SizedBox(height: 3),
                            pw.Text(
                              businessEmail.trim(),
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                          if (businessPhone.trim().isNotEmpty) ...[
                            pw.SizedBox(height: 3),
                            pw.Text(
                              businessPhone.trim(),
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                          if (businessWebsite.trim().isNotEmpty) ...[
                            pw.SizedBox(height: 3),
                            pw.Text(
                              businessWebsite.trim(),
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                          if (businessTaxNumber.trim().isNotEmpty) ...[
                            pw.SizedBox(height: 3),
                            pw.Text(
                              'Tax number: ${businessTaxNumber.trim()}',
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 16),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'INVOICE',
                          style: pw.TextStyle(
                            fontSize: 26,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blue50,
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(
                            invoiceNumber,
                            style: pw.TextStyle(
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),
                pw.Divider(color: PdfColors.blue200),
                pw.SizedBox(height: 4),
              ],
            ),
          );
        },
        footer: (context) {
          return pw.Column(
            children: [
              pw.Divider(
                color: PdfColors.grey300,
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment:
                pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Generated by InvoicePilot',
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    'Page ${context.pageNumber} of ${context.pagesCount}',
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        build: (context) {
          return [
            pw.Row(
              crossAxisAlignment:
              pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: _infoBox(
                    title: 'BILL TO',
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          clientName,
                          style: pw.TextStyle(
                            fontSize: 15,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        if (clientEmail.trim().isNotEmpty) ...[
                          pw.SizedBox(height: 4),
                          pw.Text(
                            clientEmail,
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                        if (clientPhone.trim().isNotEmpty) ...[
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Phone: $clientPhone',
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                        if (clientAddress.trim().isNotEmpty) ...[
                          pw.SizedBox(height: 4),
                          pw.Text(
                            clientAddress,
                            style: const pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 15),
                pw.Expanded(
                  child: _infoBox(
                    title: 'INVOICE DETAILS',
                    child: pw.Column(
                      crossAxisAlignment:
                      pw.CrossAxisAlignment.start,
                      children: [
                        _infoLine(
                          'Issue Date',
                          issueDate,
                        ),
                        pw.SizedBox(height: 5),
                        _infoLine(
                          'Due Date',
                          dueDate,
                        ),
                        pw.SizedBox(height: 8),
                        _statusBadge(status),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 15),

            pw.Text(
              'Items / Services',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),

            pw.SizedBox(height: 8),

            pw.TableHelper.fromTextArray(
              headers: const [
                'Description',
                'Amount',
              ],
              data: items.map((item) {
                final amount =
                    (item['amount'] as num?)
                        ?.toDouble() ??
                        0;

                return [
                  item['description']?.toString() ?? '',
                  '$currencySymbol${amount.toStringAsFixed(2)}',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF2563EB),
              ),
              cellStyle: const pw.TextStyle(
                  fontSize: 11
              ),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 11,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1),
              },
              cellAlignments: {
                1: pw.Alignment.centerRight,
              },
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
                width: 0.5,
              ),
            ),

            pw.SizedBox(height: 15),

            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 250,
                padding: const pw.EdgeInsets.all(18),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey300,
                  ),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                ),
                child: pw.Column(
                  children: [
                    _totalRow(
                      'Subtotal',
                      subtotal,
                      currencySymbol: currencySymbol,
                    ),
                    pw.SizedBox(height: 7),
                    _totalRow(
                      '$taxName (${vatRate.toStringAsFixed(
                        vatRate.truncateToDouble() == vatRate ? 0 : 2,
                      )}%)',
                      vat,
                      currencySymbol: currencySymbol,
                    ),
                    pw.SizedBox(height: 10),
                    pw.Divider(
                      color: PdfColors.grey400,
                    ),
                    pw.SizedBox(height: 5),
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: const pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFF2563EB),
                        borderRadius: pw.BorderRadius.all(
                          pw.Radius.circular(4),
                        ),
                      ),
                      child: _totalRow(
                        'Total',
                        total,
                        bold: true,
                        large: true,
                        currencySymbol: currencySymbol,
                        textColor: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            pw.SizedBox(height: 10),

            // PAYMENT METHODS
            if (_validPaymentLink(stripePaymentLink) != null ||
                _validPaymentLink(paypalPaymentLink) != null ||
                (_validPaymentLink(customPaymentLink) != null &&
                    customPaymentMethodName.trim().isNotEmpty) ||
                bankAccountName.trim().isNotEmpty ||
                bankName.trim().isNotEmpty ||
                bankAccountNumber.trim().isNotEmpty ||
                bankRouting.trim().isNotEmpty ||
                bankPaymentInstructions.trim().isNotEmpty) ...[
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PAYMENT METHODS',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 5),

                    if (_validPaymentLink(stripePaymentLink) != null) ...[
                      pw.Text(
                        'Stripe: ${_validPaymentLink(stripePaymentLink)}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.SizedBox(height: 5),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: _validPaymentLink(stripePaymentLink)!,
                        width: 85,
                        height: 85,
                      ),
                      pw.SizedBox(height: 10),
                    ],

                    if (_validPaymentLink(paypalPaymentLink) != null) ...[
                      pw.Text(
                        'PayPal: ${_validPaymentLink(paypalPaymentLink)}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.SizedBox(height: 5),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: _validPaymentLink(paypalPaymentLink)!,
                        width: 85,
                        height: 85,
                      ),
                      pw.SizedBox(height: 10),
                    ],

                    if (_validPaymentLink(customPaymentLink) != null &&
                        customPaymentMethodName.trim().isNotEmpty) ...[
                      pw.Text(
                        '${customPaymentMethodName.trim()}: '
                            '${_validPaymentLink(customPaymentLink)}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.SizedBox(height: 5),
                      pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: _validPaymentLink(customPaymentLink)!,
                        width: 72,
                        height: 72,
                      ),
                      pw.SizedBox(height: 10),
                    ],

                    if (bankAccountName.trim().isNotEmpty)
                      pw.Text(
                        'Account holder: ${bankAccountName.trim()}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),

                    if (bankName.trim().isNotEmpty)
                      pw.Text(
                        'Bank: ${bankName.trim()}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),

                    if (bankAccountNumber.trim().isNotEmpty)
                      pw.Text(
                        'Account number / IBAN: ${bankAccountNumber.trim()}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),

                    if (bankRouting.trim().isNotEmpty)
                      pw.Text(
                        'Routing / BIC: ${bankRouting.trim()}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),

                    if (bankPaymentInstructions.trim().isNotEmpty) ...[
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Payment instructions: ${bankPaymentInstructions.trim()}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
            ],

            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 12,
              ),
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF2563EB),
                borderRadius: pw.BorderRadius.all(
                  pw.Radius.circular(8),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'We appreciate your trust in our services.',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Please contact us if you have any questions about this invoice.',
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _infoBox({
    required String title,
    required pw.Widget child,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF1F5F9),
        borderRadius: const pw.BorderRadius.all(
          pw.Radius.circular(6),
        ),
        border: pw.Border.all(
          color: PdfColors.grey300,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment:
        pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey600,
            ),
          ),
          pw.SizedBox(height: 7),
          child,
        ],
      ),
    );
  }

  static pw.Widget _infoLine(
      String label,
      String value,
      ) {
    return pw.Row(
      mainAxisAlignment:
      pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static pw.Widget _statusBadge(String status) {
    PdfColor background;
    PdfColor textColor;

    switch (status.toLowerCase()) {
      case 'paid':
        background = PdfColors.green100;
        textColor = PdfColors.green800;
        break;

      case 'overdue':
        background = PdfColors.red100;
        textColor = PdfColors.red800;
        break;

      default:
        background = PdfColors.blue100;
        textColor = PdfColors.blue800;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: pw.BoxDecoration(
        color: background,
        borderRadius: const pw.BorderRadius.all(
          pw.Radius.circular(12),
        ),
      ),
      child: pw.Text(
        status.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  static pw.Widget _totalRow(
      String label,
      double amount, {
        bool bold = false,
        bool large = false,
        PdfColor? textColor,
        required String currencySymbol,
      }) {
    final style = pw.TextStyle(
      fontSize: large
          ? 18
          : bold
          ? 13
          : 11,
      fontWeight: bold
          ? pw.FontWeight.bold
          : pw.FontWeight.normal,
      color: textColor,
    );

    return pw.Row(
      mainAxisAlignment:
      pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: style,
        ),
        pw.Text(
          '$currencySymbol${amount.toStringAsFixed(2)}',
          style: style,
        ),
      ],
    );
  }

  // ADD THIS NEW HELPER BELOW
  static String? _validPaymentLink(String link) {
    final trimmedLink = link.trim();
    final uri = Uri.tryParse(trimmedLink);

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      return null;
    }

    return trimmedLink;
  }
}
