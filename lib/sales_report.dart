import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SalesReportPage extends StatefulWidget {
  const SalesReportPage({Key? key}) : super(key: key);

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  Map<String, Map<String, dynamic>> productSales = {};
  bool isLoading = true;
  bool hasDeliveredOrders = false;

  @override
  void initState() {
    super.initState();
    fetchSalesData();
  }

  Future<void> fetchSalesData() async {
    try {
      final productsSnapshot = await FirebaseFirestore.instance.collection('products').get();
      final Map<String, Map<String, dynamic>> sales = {};

      for (var productDoc in productsSnapshot.docs) {
        final productId = productDoc.id;
        final productData = productDoc.data() as Map<String, dynamic>;
        sales[productId] = {
          'name': productData['name'] ?? 'Unnamed Product',
          'quantitySold': 0,
        };
      }

      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('deliveryStatus', isEqualTo: 'Delivered')
          .get();

      if (ordersSnapshot.docs.isEmpty) {
        setState(() {
          productSales = sales;
          isLoading = false;
          hasDeliveredOrders = false;
        });
        return;
      }

      hasDeliveredOrders = true;

      for (var orderDoc in ordersSnapshot.docs) {
        final orderData = orderDoc.data() as Map<String, dynamic>;
        final products = orderData['products'] as Map<String, dynamic>;

        for (var entry in products.entries) {
          final productId = entry.key;
          final quantity = entry.value['quantity'] ?? 0;

          if (sales.containsKey(productId)) {
            sales[productId]!['quantitySold'] += quantity;
          }
        }
      }

      final sortedSales = Map.fromEntries(
        sales.entries.toList()
          ..sort((a, b) =>
              (b.value['quantitySold'] as int).compareTo(a.value['quantitySold'] as int)),
      );

      setState(() {
        productSales = sortedSales;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error fetching sales data: $e');
    }
  }

  List<BarChartGroupData> buildBarChartData() {
    int index = 0;
    return productSales.entries.map((entry) {
      final quantity = entry.value['quantitySold'] as int;
      final bar = BarChartGroupData(
        x: index++,
        barRods: [
          BarChartRodData(
            toY: quantity.toDouble(),
            color: Colors.blue.shade600,
            width: 18,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      );
      return bar;
    }).toList();
  }

  List<String> getProductNames() {
    return productSales.values.map((e) => e['name'].toString()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final productNames = getProductNames();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales Report"),
        backgroundColor: Colors.blue.shade800,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : productSales.isEmpty
          ? Center(
        child: hasDeliveredOrders
            ? const Text("No products found.")
            : const Text("No delivered orders yet."),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Text(
              "Sales Chart",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300, // Adjust the height of the chart
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  maxY: productSales.values
                      .map((e) => e['quantitySold'] as int)
                      .fold<double>(0, (prev, curr) => curr > prev ? curr.toDouble() : prev) +
                      5,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < productSales.length) {
                            final name = productSales.values.elementAt(index)['name'] as String;
                            return Transform.translate(
                              offset: const Offset(0, 10),
                              child: Text(
                                name,
                                style: const TextStyle(fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                        reservedSize: 50,
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  barGroups: productSales.entries
                      .toList()
                      .asMap()
                      .entries
                      .map(
                        (entry) => BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: (entry.value.value['quantitySold'] as int).toDouble(),
                          width: 18,
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.blue.shade600,
                        ),
                      ],
                    ),
                  )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: productSales.length,
              itemBuilder: (context, index) {
                final entry = productSales.entries.elementAt(index);
                final productId = entry.key;
                final data = entry.value;
                final name = data['name'];
                final quantitySold = data['quantitySold'];

                return Card(
                  color: Colors.blue.shade50,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: CircleAvatar(
                      backgroundColor: quantitySold > 0
                          ? Colors.blue.shade400
                          : Colors.grey,
                      child: Text(
                        (index + 1).toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      "Product ID: $productId\nSales: ${quantitySold > 0 ? quantitySold : 'No orders yet'}",
                      style: const TextStyle(height: 1.5),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
