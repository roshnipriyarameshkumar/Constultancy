// reports_page.dart
import 'package:flutter/material.dart';
import 'total_sales_report.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({Key? key}) : super(key: key);

  Widget _buildReportCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.indigo,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildReportCard(
            title: "Total Sales Report",
            description: "Generate day-wise, week-wise, or month-wise total sales in PDF format.",
            icon: Icons.bar_chart,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TotalSalesReportPage()),
              );
            },
          ),
          _buildReportCard(
            title: "Product-wise Report",
            description: "Coming soon: Report for each product’s sales performance.",
            icon: Icons.shopping_bag,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Product-wise report is under development."),
              ));
            },
          ),
          _buildReportCard(
            title: "Stock Report",
            description: "Coming soon: Report on current stock and low inventory alerts.",
            icon: Icons.inventory,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Stock report is under development."),
              ));
            },
          ),
        ],
      ),
    );
  }
}
