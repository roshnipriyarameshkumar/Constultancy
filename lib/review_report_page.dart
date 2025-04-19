import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ReviewReportPage extends StatefulWidget {
  @override
  _ReviewReportPageState createState() => _ReviewReportPageState();
}

class _ReviewReportPageState extends State<ReviewReportPage> {
  String reportType = 'Day Wise';
  DateTime? startDate;
  DateTime? endDate;
  List<Map<String, dynamic>> reportData = [];
  bool isLoading = false;

  final List<String> reportTypes = [
    'Day Wise',
    'Week Wise',
    'Month Wise',
    'Year Wise'
  ];

  // Function to select input range (dates or month/year range)
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
                              child: Text(DateFormat.MMMM().format(DateTime(0, i + 1)))),
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
                              child: Text(DateFormat.MMMM().format(DateTime(0, i + 1)))),
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

  // Function to generate the report from Firestore data
  Future<void> generateReport() async {
    if (startDate == null || endDate == null) return;

    setState(() {
      isLoading = true;
      reportData.clear();
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .get();

      int serial = 1;
      final format = DateFormat('dd-MM-yyyy');

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

        if (timestamp == null || timestamp.isBefore(startDate!) || timestamp.isAfter(endDate!)) continue;

        final productId = data['productId'] ?? 'N/A';
        final productName = data['productName'] ?? 'N/A';
        final rating = data['rating'] ?? 0;
        final review = data['review'] ?? 'No review';

        reportData.add({
          'serial': serial++,
          'date': format.format(timestamp),
          'productId': productId,
          'productName': productName,
          'rating': rating,
          'review': review,
        });
      }
    } catch (e) {
      print('Error generating report: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  // Function to generate and download the PDF report
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
                headers: ['S.No', 'Product ID', 'Product Name', 'Rating', 'Review'],
                data: reportData.map((item) {
                  return [
                    item['serial'].toString(),
                    item['productId'],
                    item['productName'],
                    item['rating'].toString(),
                    item['review'],
                  ];
                }).toList(),
                cellStyle: pw.TextStyle(fontSize: 10),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/review_sales_report.pdf");

    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Review Sales Report'), backgroundColor: Colors.indigo),
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
                      DataColumn(label: Text('Product ID')),
                      DataColumn(label: Text('Product Name')),
                      DataColumn(label: Text('Rating')),
                      DataColumn(label: Text('Review')),
                    ],
                    rows: reportData.map((item) {
                      return DataRow(cells: [
                        DataCell(Text(item['serial'].toString())),
                        DataCell(Text(item['productId'])),
                        DataCell(Text(item['productName'])),
                        DataCell(Text(item['rating'].toString())),
                        DataCell(Text(item['review'])),
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
                  label: Text('Download Report'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: ReviewReportPage()));
}
