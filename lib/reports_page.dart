import 'package:flutter/material.dart';
import 'total_sales_page.dart';
import 'order_sales_page.dart';
import 'review_report_page.dart'; // Import the new review report page

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('Reports', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Total Sales Report Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.bar_chart, color: Colors.indigo),
              title: Text('Total Sales Report', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Generate sales PDF for delivered products'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TotalSalesPage()),
                );
              },
            ),
          ),

          // Order Sales Report Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.receipt_long, color: Colors.indigo),
              title: Text('Order Sales Report', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Generate sales PDF for placed orders'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderSalesPage()),
                );
              },
            ),
          ),

          // Review Report Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(Icons.reviews, color: Colors.indigo),
              title: Text('Review Report', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('View and generate PDF for product reviews'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReviewReportPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
