import 'package:cloud_firestore/cloud_firestore.dart';
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
      // Fetch all products first
      final productsSnapshot = await FirebaseFirestore.instance.collection('products').get();

      final Map<String, Map<String, dynamic>> sales = {};

      // Initialize all products with 0 quantity
      for (var productDoc in productsSnapshot.docs) {
        final productId = productDoc.id;
        final productData = productDoc.data() as Map<String, dynamic>;
        sales[productId] = {
          'name': productData['name'] ?? 'Unnamed Product',
          'quantitySold': 0,
        };
      }

      // Fetch only delivered orders
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

      // Aggregate product sales from delivered orders
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

      // Sort products by quantitySold (descending)
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

  @override
  Widget build(BuildContext context) {
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
          : ListView.builder(
        padding: const EdgeInsets.all(10),
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
    );
  }
}
