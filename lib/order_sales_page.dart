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
        int selectedYear = DateTime.now().year;
        int selectedStartMonth = 1;
        int selectedEndMonth = 12;
        await showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text('Select Month Range'),
              content: StatefulBuilder(
                builder: (context, setStateDialog) {
                  return Column(
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
                        onChanged: (val) => setStateDialog(() => selectedStartMonth = val!),
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
                        onChanged: (val) => setStateDialog(() => selectedEndMonth = val!),
                        decoration: InputDecoration(labelText: 'End Month'),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        initialValue: selectedYear.toString(),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Year'),
                        onChanged: (val) => setStateDialog(() {
                          selectedYear = int.tryParse(val) ?? selectedYear;
                        }),
                      ),
                    ],
                  );
                },
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
        int selectedStartYear = DateTime.now().year - 1;
        int selectedEndYear = DateTime.now().year;
        await showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text('Select Year Range'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: selectedStartYear.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Start Year'),
                    onChanged: (val) {
                      selectedStartYear = int.tryParse(val) ?? selectedStartYear;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    initialValue: selectedEndYear.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'End Year'),
                    onChanged: (val) {
                      selectedEndYear = int.tryParse(val) ?? selectedEndYear;
                    },
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
                headers: ['S.No', 'Date', 'Product Name', 'Qty', 'Amount (Rs.)'],
                data: reportData.map((item) {
                  return [
                    item['serial'].toString(),
                    item['date'],
                    item['name'],
                    item['quantity'].toString(),
                    'Rs. ${item['amount'].toStringAsFixed(2)}',
                  ];
                }).toList(),
                cellStyle: pw.TextStyle(fontSize: 10),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Grand Total: Rs. ${grandTotal.toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/total_sales_report.pdf");

    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
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
                      });
                    },
                    decoration: InputDecoration(labelText: 'Select Report Type'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.date_range),
                  onPressed: selectInputRange,
                ),
              ],
            ),
            SizedBox(height: 20),
            if (isLoading)
              Expanded(child: Center(child: CircularProgressIndicator()))
            else if (reportData.isEmpty)
              Expanded(child: Center(child: Text('No data available for selected range.')))
            else
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('S.No')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Product Name')),
                      DataColumn(label: Text('Qty')),
                      DataColumn(label: Text('Amount')),
                    ],
                    rows: reportData.map((item) {
                      return DataRow(cells: [
                        DataCell(Text(item['serial'].toString())),
                        DataCell(Text(item['date'])),
                        DataCell(Text(item['name'])),
                        DataCell(Text(item['quantity'].toString())),
                        DataCell(Text('Rs. ${item['amount'].toStringAsFixed(2)}')),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            if (reportData.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton.icon(
                  onPressed: downloadReportAsPDF,
                  icon: Icon(Icons.download, color: Colors.white),
                  label: Text(
                    'Download PDF',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
