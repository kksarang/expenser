import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import 'analytics_service.dart';

class PdfExportService {
  Future<void> exportAnalyticsReport({
    required AnalyticsType type,
    required DateTime selectedDate,
    DateTime? customStartDate,
    DateTime? customEndDate,
    required double totalIncome,
    required double totalExpense,
    required double balance,
    required double savingsRate,
    required Map<String, double> categoryWiseExpense,
    required Map<String, int> categoryCounts,
    required Map<String, String>
    categoryNames, // categoryId -> name mapping for display
    bool share = true,
  }) async {
    final pdf = pw.Document();

    String periodTitle = _getPeriodTitle(
      type,
      selectedDate,
      customStartDate,
      customEndDate,
    );

    // Currency formatter
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: 'Rs.',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(periodTitle),
            pw.SizedBox(height: 20),
            _buildSummary(
              totalIncome: totalIncome,
              totalExpense: totalExpense,
              balance: balance,
              savingsRate: savingsRate,
              currencyFormat: currencyFormat,
            ),
            pw.SizedBox(height: 30),
            _buildCategoryTable(
              categoryWiseExpense: categoryWiseExpense,
              categoryCounts: categoryCounts,
              categoryNames: categoryNames,
              totalExpense: totalExpense,
              currencyFormat: currencyFormat,
            ),
          ];
        },
      ),
    );

    final String filename =
        'Expenser_Report_${DateFormat('MMM_yyyy').format(selectedDate)}.pdf';

    final bytes = await pdf.save();
    if (share) {
      await Printing.sharePdf(bytes: bytes, filename: filename);
    } else {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: filename,
      );
    }
  }

  pw.Widget _buildHeader(String periodTitle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          "Expenser Analytics Report",
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          periodTitle,
          style: const pw.TextStyle(fontSize: 16, color: PdfColors.grey700),
        ),
        pw.Divider(color: PdfColors.grey400),
      ],
    );
  }

  pw.Widget _buildSummary({
    required double totalIncome,
    required double totalExpense,
    required double balance,
    required double savingsRate,
    required NumberFormat currencyFormat,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Summary",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          _buildSummaryRow(
            "Total Income:",
            currencyFormat.format(totalIncome),
            PdfColors.green700,
          ),
          pw.SizedBox(height: 8),
          _buildSummaryRow(
            "Total Expense:",
            currencyFormat.format(totalExpense),
            PdfColors.red700,
          ),
          pw.SizedBox(height: 8),
          _buildSummaryRow(
            "Balance:",
            currencyFormat.format(balance),
            balance >= 0 ? PdfColors.black : PdfColors.red900,
          ),
          pw.SizedBox(height: 8),
          _buildSummaryRow(
            "Savings Rate:",
            "${savingsRate.toStringAsFixed(1)}%",
            PdfColors.blue700,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryRow(String label, String value, PdfColor valueColor) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 14)),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildCategoryTable({
    required Map<String, double> categoryWiseExpense,
    required Map<String, int> categoryCounts,
    required Map<String, String> categoryNames,
    required double totalExpense,
    required NumberFormat currencyFormat,
  }) {
    // Sort categories by amount
    final sortedCategories = categoryWiseExpense.keys.toList()
      ..sort(
        (a, b) => categoryWiseExpense[b]!.compareTo(categoryWiseExpense[a]!),
      );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          "Category Breakdown",
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 12),
        pw.Table.fromTextArray(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          headerStyle: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
          cellAlignment: pw.Alignment.centerLeft,
          headers: ['Category', 'Transactions', 'Amount', '% of Total'],
          data: sortedCategories.map((id) {
            final name = categoryNames[id] ?? 'Unknown';
            final amount = categoryWiseExpense[id]!;
            final count = categoryCounts[id] ?? 0;
            final percentage = totalExpense > 0
                ? (amount / totalExpense * 100).toStringAsFixed(1)
                : '0.0';
            return [
              name,
              count.toString(),
              currencyFormat.format(amount),
              '$percentage%',
            ];
          }).toList(),
        ),
      ],
    );
  }

  String _getPeriodTitle(
    AnalyticsType type,
    DateTime selectedDate,
    DateTime? customStart,
    DateTime? customEnd,
  ) {
    switch (type) {
      case AnalyticsType.week:
        final startOfWeek = selectedDate.subtract(
          Duration(days: selectedDate.weekday - 1),
        );
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        final format = DateFormat('dd MMM yyyy');
        return "Week: ${format.format(startOfWeek)} - ${format.format(endOfWeek)}";
      case AnalyticsType.month:
        return "Month: ${DateFormat('MMMM yyyy').format(selectedDate)}";
      case AnalyticsType.year:
        return "Year: ${DateFormat('yyyy').format(selectedDate)}";
      case AnalyticsType.custom:
        if (customStart != null && customEnd != null) {
          final format = DateFormat('dd MMM yyyy');
          return "Custom: ${format.format(customStart)} - ${format.format(customEnd)}";
        }
        return "Custom Range";
    }
  }
}
