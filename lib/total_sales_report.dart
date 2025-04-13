import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart'; // Make sure this is in pubspec.yaml

class TotalSalesReportPage extends StatefulWidget {
  const TotalSalesReportPage({Key? key}) : super(key: key);

  @override
  State<TotalSalesReportPage> createState() => _TotalSalesReportPageState();
}

class _TotalSalesReportPageState extends State<TotalSalesReportPage> {
  DateTimeRange? selectedDateRange;

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  Future<void> _generatePdfReport() async {
    if (selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date range")),
      );
      return;
    }

    try {
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('timestamp', isGreaterThanOrEqualTo: selectedDateRange!.start)
          .where('timestamp', isLessThanOrEqualTo: selectedDateRange!.end)
          .get();

      final pdf = pw.Document();
      final dateFormat = DateFormat('dd-MM-yyyy');
      double totalSales = 0;
      List<List<String>> productData = [];

      for (var doc in ordersSnapshot.docs) {
        final orderData = doc.data();
        final productsMap = orderData['products'];

        if (productsMap is Map<String, dynamic>) {
          for (var entry in productsMap.entries) {
            final product = entry.value;
            final name = product['name']?.toString() ?? 'Unnamed';
            final quantity = int.tryParse(product['quantity'].toString()) ?? 0;
            final price = double.tryParse(product['price'].toString()) ?? 0.0;
            final amount = price * quantity;
            totalSales += amount;

            productData.add([
              name,
              quantity.toString(),
              amount.toStringAsFixed(2),
            ]);
          }
        }
      }

      pdf.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Center(
              child: pw.Text("Total Sales Report",
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              "Date Range: ${dateFormat.format(selectedDateRange!.start)} - ${dateFormat.format(selectedDateRange!.end)}",
              style: pw.TextStyle(fontSize: 14),
            ),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: ['Product Name', 'Quantity', 'Amount (₹)'],
              data: productData,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              "Total Sales: ₹${totalSales.toStringAsFixed(2)}",
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      );

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/Total_Sales_Report.pdf');
      await file.writeAsBytes(await pdf.save());

      // Open the file
      await OpenFile.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating PDF: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateRangeText = selectedDateRange == null
        ? 'No date range selected'
        : '${DateFormat('dd-MM-yyyy').format(selectedDateRange!.start)} - ${DateFormat('dd-MM-yyyy').format(selectedDateRange!.end)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Sales Report', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ListTile(
              title: const Text("Selected Range"),
              subtitle: Text(dateRangeText),
              trailing: ElevatedButton.icon(
                onPressed: _pickDateRange,
                icon: const Icon(Icons.calendar_today),
                label: const Text("Pick Date Range"),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _generatePdfReport,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Generate PDF Report"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }
}
