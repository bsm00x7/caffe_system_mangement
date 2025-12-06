import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';

import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportExportService {
  /// Export sales report to PDF
  static Future<String> exportSalesPDF({
    required double totalRevenue,
    required double todayRevenue,
    required int totalPurchases,
    required int todayPurchases,
    required List<double> weeklySales,
    required List<Map<String, dynamic>> recentPurchases,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormatter = DateFormat('MMMM d, y');
    final timeFormatter = DateFormat('h:mm a');

    // Add page to PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 20),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(width: 2, color: PdfColors.deepPurple),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Sales Report',
                    style: pw.TextStyle(
                      fontSize: 28,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.deepPurple,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Generated on ${dateFormatter.format(now)} at ${timeFormatter.format(now)}',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // Summary Statistics
            pw.Text(
              'Summary',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 15),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  'Total Revenue',
                  'DT ${totalRevenue.toStringAsFixed(2)}',
                  'All time',
                ),
                _buildStatCard(
                  'Total Purchases',
                  totalPurchases.toString(),
                  'Completed',
                ),
              ],
            ),

            pw.SizedBox(height: 15),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  'Today\'s Revenue',
                  'DT ${todayRevenue.toStringAsFixed(2)}',
                  dateFormatter.format(now),
                ),
                _buildStatCard(
                  'Today\'s Purchases',
                  todayPurchases.toString(),
                  'Transactions',
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            // Weekly Sales Chart
            pw.Text(
              'Weekly Sales',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 15),

            pw.Container(
              height: 200,
              child: pw.Chart(
                grid: pw.CartesianGrid(
                  xAxis: pw.FixedAxis.fromStrings(
                    ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                    marginStart: 30,
                    marginEnd: 0,
                  ),
                  yAxis: pw.FixedAxis(
                    [0, weeklySales.reduce((a, b) => a > b ? a : b)],
                    divisions: true,
                  ),
                ),
                datasets: [
                  pw.LineDataSet(
                    legend: 'Sales (DT)',

                    drawSurface: true,
                    isCurved: true,
                    color: PdfColors.deepPurple,
                    data: List.generate(
                      weeklySales.length,
                      (index) => pw.PointChartValue(index.toDouble(), weeklySales[index]),
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // Recent Purchases Table
            pw.Text(
              'Recent Purchases',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 15),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                  ),
                  children: [
                    _buildTableCell('Employee', isHeader: true),
                    _buildTableCell('Item', isHeader: true),
                    _buildTableCell('Quantity', isHeader: true),
                    _buildTableCell('Total', isHeader: true),
                    _buildTableCell('Date', isHeader: true),
                  ],
                ),
                // Data rows
                ...recentPurchases.take(10).map((purchase) {
                  final userName = purchase['users']?['name'] ?? 'Unknown';
                  final itemName = purchase['items']?['item_name'] ?? 'Unknown';
                  final quantity = purchase['quantity']?.toString() ?? '0';
                  final total = (purchase['total_amount'] as num?)?.toDouble() ?? 0.0;
                  final date = purchase['purchase_date'] != null
                      ? DateFormat('MMM d, HH:mm').format(
                          DateTime.parse(purchase['purchase_date']),
                        )
                      : 'N/A';

                  return pw.TableRow(
                    children: [
                      _buildTableCell(userName),
                      _buildTableCell(itemName),
                      _buildTableCell(quantity),
                      _buildTableCell('DT ${total.toStringAsFixed(2)}'),
                      _buildTableCell(date),
                    ],
                  );
                }),
              ],
            ),

            pw.SizedBox(height: 20),

            // Footer
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text(
              'Cafe Management System - Sales Report',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ];
        },
      ),
    );

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'sales_report_${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  /// Export sales report to CSV
  static Future<String> exportSalesCSV({
    required double totalRevenue,
    required double todayRevenue,
    required int totalPurchases,
    required int todayPurchases,
    required List<double> weeklySales,
    required List<Map<String, dynamic>> recentPurchases,
  }) async {
    final now = DateTime.now();
    final dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    List<List<dynamic>> rows = [];

    // Header
    rows.add(['Cafe Management System - Sales Report']);
    rows.add(['Generated on', dateFormatter.format(now)]);
    rows.add([]);

    // Summary Statistics
    rows.add(['SUMMARY STATISTICS']);
    rows.add(['Metric', 'Value', 'Period']);
    rows.add(['Total Revenue', 'DT ${totalRevenue.toStringAsFixed(2)}', 'All time']);
    rows.add(['Total Purchases', totalPurchases.toString(), 'Completed']);
    rows.add(['Today\'s Revenue', 'DT ${todayRevenue.toStringAsFixed(2)}', DateFormat('MMMM d, y').format(now)]);
    rows.add(['Today\'s Purchases', todayPurchases.toString(), 'Transactions']);
    rows.add([]);

    // Weekly Sales
    rows.add(['WEEKLY SALES']);
    rows.add(['Day', 'Sales (DT)']);
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    for (int i = 0; i < weeklySales.length; i++) {
      rows.add([days[i], weeklySales[i].toStringAsFixed(2)]);
    }
    rows.add([]);

    // Recent Purchases
    rows.add(['RECENT PURCHASES']);
    rows.add(['Employee', 'Item', 'Quantity', 'Total (DT)', 'Date & Time']);
    
    for (var purchase in recentPurchases) {
      final userName = purchase['users']?['name'] ?? 'Unknown';
      final itemName = purchase['items']?['item_name'] ?? 'Unknown';
      final quantity = purchase['quantity']?.toString() ?? '0';
      final total = (purchase['total_amount'] as num?)?.toDouble() ?? 0.0;
      final date = purchase['purchase_date'] != null
          ? DateFormat('yyyy-MM-dd HH:mm').format(
              DateTime.parse(purchase['purchase_date']),
            )
          : 'N/A';

      rows.add([
        userName,
        itemName,
        quantity,
        total.toStringAsFixed(2),
        date,
      ]);
    }

    // Convert to CSV string
    String csv = const ListToCsvConverter().convert(rows);

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'sales_report_${DateFormat('yyyyMMdd_HHmmss').format(now)}.csv';
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csv);

    return file.path;
  }

  /// Helper to build stat card in PDF
  static pw.Widget _buildStatCard(String title, String value, String subtitle) {
    return pw.Container(
      width: 250,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.deepPurple,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            subtitle,
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build table cell in PDF
  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.black : PdfColors.grey800,
        ),
      ),
    );
  }

  /// Open the exported file
  static Future<void> openFile(String filePath) async {
    await OpenFile.open(filePath);
  }
}
