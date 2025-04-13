import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class OrderSalesPage extends StatefulWidget {
  @override
  _OrderSalesPageState createState() => _OrderSalesPageState();
}

class _OrderSalesPageState extends State<OrderSalesPage> {
  String reportType = 'Day Wise';
  DateTime? startDate;
  DateTime? endDate;
  List<Map<String, dynamic>> reportData = [];
  num grandTotal = 0;
  bool isLoading = false;

  final List<String> reportTypes = [
    'Day Wise',
    'Week Wise',
    'Month Wise',
    'Year Wise'
  ];

  Future<void> selectInputRange() async {
    switch (reportType) {
      case 'Day Wise':
      case 'Week Wise':
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2023),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            startDate = picked.start;
            endDate = picked.end.add(Duration(hours: 23, minutes: 59, seconds: 59));
          });
          await generateReport();
        }
        break;

      case 'Month Wise':
        await showDialog(
          context: context,
          builder: (_) {
            int selectedYear = DateTime.now().year;
            int selectedStartMonth = 1;
            int selectedEndMonth = 12;

            return AlertDialog(
              title: Text('Select Month Range'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: selectedStartMonth,
                    items: List.generate(
                      12,
                          (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text(DateFormat.MMMM().format(DateTime(0, i + 1))),
                      ),
                    ),
                    onChanged: (val) => selectedStartMonth = val!,
                    decoration: InputDecoration(labelText: 'Start Month'),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: selectedEndMonth,
                    items: List.generate(
                      12,
                          (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text(DateFormat.MMMM().format(DateTime(0, i + 1))),
                      ),
                    ),
                    onChanged: (val) => selectedEndMonth = val!,
                    decoration: InputDecoration(labelText: 'End Month'),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    initialValue: selectedYear.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Year'),
                    onChanged: (val) =>
                    selectedYear = int.tryParse(val) ?? selectedYear,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      startDate = DateTime(selectedYear, selectedStartMonth, 1);
                      endDate = DateTime(selectedYear, selectedEndMonth + 1, 0, 23, 59, 59);
                    });
                    generateReport();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        break;

      case 'Year Wise':
        await showDialog(
          context: context,
          builder: (_) {
            int selectedStartYear = DateTime.now().year - 1;
            int selectedEndYear = DateTime.now().year;
            return AlertDialog(
              title: Text('Select Year Range'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: selectedStartYear.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Start Year'),
                    onChanged: (val) =>
                    selectedStartYear = int.tryParse(val) ?? selectedStartYear,
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    initialValue: selectedEndYear.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'End Year'),
                    onChanged: (val) =>
                    selectedEndYear = int.tryParse(val) ?? selectedEndYear,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      startDate = DateTime(selectedStartYear, 1, 1);
                      endDate = DateTime(selectedEndYear, 12, 31, 23, 59, 59);
                    });
                    generateReport();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        break;
    }
  }

  Future<void> generateReport() async {
    if (startDate == null || endDate == null) return;

    setState(() {
      isLoading = true;
      reportData.clear();
      grandTotal = 0;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('deliveryStatus', whereIn: ['Placed', 'Shipped'])
          .get();

      int serial = 1;
      final format = DateFormat('dd-MM-yyyy');

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final time = (data['timestamp'] as Timestamp?)?.toDate();

        if (time == null || time.isBefore(startDate!) || time.isAfter(endDate!)) continue;

        final products = Map<String, dynamic>.from(data['products'] ?? {});
        for (var entry in products.entries) {
          final product = entry.value;
          final name = product['name'] ?? 'N/A';
          final qty = int.tryParse(product['quantity'].toString()) ?? 0;
          final price = num.tryParse(product['price'].toString()) ?? 0;
          final amount = qty * price;

          reportData.add({
            'serial': serial++,
            'date': format.format(time),
            'name': name,
            'quantity': qty,
            'amount': amount,
          });

          grandTotal += amount;
        }
      }
    } catch (e) {
      print('Error generating report: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> downloadReportAsPDF() async {
    final pdf = pw.Document();
    final format = DateFormat('dd MMM yyyy');
    final start = startDate != null ? format.format(startDate!) : '';
    final end = endDate != null ? format.format(endDate!) : '';

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('AMSAM TEXTILES',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  '$reportType Report | $start - $end',
                  style: pw.TextStyle(fontSize: 14),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['S.No', 'Date', 'Product Name', 'Qty', 'Amount'],
                data: reportData.map((item) {
                  return [
                    item['serial'].toString(),
                    item['date'],
                    item['name'],
                    item['quantity'].toString(),
                    'Rs.${item['amount']}',
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Grand Total: ₹$grandTotal',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/order_sales_report.pdf");

    await file.writeAsBytes(await pdf.save());
    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order Sales Report'), backgroundColor: Colors.indigo),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: reportType,
                    items: reportTypes
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        reportType = val!;
                        reportData.clear();
                        startDate = null;
                        endDate = null;
                      });
                    },
                    decoration: InputDecoration(
                        labelText: "Select Report Type",
                        border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: selectInputRange,
                  icon: Icon(Icons.calendar_today, color: Colors.white),
                  label: Text('Pick Range', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (startDate != null && endDate != null)
              Text(
                'From ${DateFormat('dd MMM yyyy').format(startDate!)} to ${DateFormat('dd MMM yyyy').format(endDate!)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 20),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (reportData.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: reportData.length,
                  itemBuilder: (context, index) {
                    final item = reportData[index];
                    return Card(
                      child: ListTile(
                        title: Text(item['name']),
                        subtitle: Text('Qty: ${item['quantity']} - Amount: ₹${item['amount']}'),
                        trailing: Text(item['date']),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: downloadReportAsPDF,
              icon: Icon(Icons.download, color: Colors.white),
              label: Text('Download Report', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }
}
