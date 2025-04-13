import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class TotalSalesPage extends StatefulWidget {
  @override
  _TotalSalesPageState createState() => _TotalSalesPageState();
}

class _TotalSalesPageState extends State<TotalSalesPage> {
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
            endDate = picked.end;
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
                          child: Text(
                              DateFormat.MMMM().format(DateTime(0, i + 1))),
                        )),
                    onChanged: (val) => selectedStartMonth = val!,
                    decoration: InputDecoration(labelText: 'Start Month'),
                  ),
                  DropdownButtonFormField<int>(
                    value: selectedEndMonth,
                    items: List.generate(
                        12,
                            (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text(
                              DateFormat.MMMM().format(DateTime(0, i + 1))),
                        )),
                    onChanged: (val) => selectedEndMonth = val!,
                    decoration: InputDecoration(labelText: 'End Month'),
                  ),
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
                      startDate =
                          DateTime(selectedYear, selectedStartMonth, 1);
                      endDate = DateTime(
                          selectedYear, selectedEndMonth + 1, 0); // end of month
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
                    onChanged: (val) => selectedStartYear =
                        int.tryParse(val) ?? selectedStartYear,
                  ),
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
                      endDate = DateTime(selectedEndYear, 12, 31);
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
          .where('deliveryStatus', isEqualTo: 'Delivered')
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
    final rupee = 'Rs.';
    final format = DateFormat('dd-MM-yyyy');

    final title = "AMSAM TEXTILES";
    final subtitle =
        "$reportType Report | ${format.format(startDate!)} to ${format.format(endDate!)}";

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                  child: pw.Text(title,
                      style: pw.TextStyle(
                          fontSize: 22, fontWeight: pw.FontWeight.bold))),
              pw.SizedBox(height: 5),
              pw.Center(
                  child: pw.Text(subtitle,
                      style: pw.TextStyle(
                          fontSize: 14, fontStyle: pw.FontStyle.italic))),
              pw.SizedBox(height: 15),
              pw.Table.fromTextArray(
                headers: ['S.No', 'Date', 'Product Name', 'Qty', 'Amount ($rupee)'],
                data: reportData
                    .map((e) => [
                  e['serial'].toString(),
                  e['date'],
                  e['name'],
                  e['quantity'].toString(),
                  '$rupee${e['amount']}'
                ])
                    .toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 10),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Grand Total: $rupee$grandTotal',
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/sales_report.pdf');
    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: Text('Total Sales Report'), backgroundColor: Colors.indigo),
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
                        .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
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
                  label:
                  Text('Pick Range', style: TextStyle(color: Colors.white)),
                  style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                )
              ],
            ),
            SizedBox(height: 16),
            if (startDate != null && endDate != null)
              Text(
                'From ${DateFormat('dd MMM yyyy').format(startDate!)} to ${DateFormat('dd MMM yyyy').format(endDate!)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 10),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (reportData.isNotEmpty) ...[
              Expanded(
                child: ListView.builder(
                  itemCount: reportData.length,
                  itemBuilder: (context, index) {
                    final item = reportData[index];
                    return ListTile(
                      leading: Text(item['serial'].toString()),
                      title: Text(item['name']),
                      subtitle: Text(
                          'Date: ${item['date']} | Qty: ${item['quantity']}'),
                      trailing: Text(
                        '₹${item['amount']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
              Text('Grand Total: ₹$grandTotal',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: downloadReportAsPDF,
                icon: Icon(Icons.download, color: Colors.white),
                label: Text('Download PDF', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
