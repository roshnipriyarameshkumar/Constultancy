import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  void updateStatus(String orderId, String newStatus) {
    FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'deliveryStatus': newStatus,
    });
  }

  bool isCustomOrder(Map<String, dynamic> products) {
    return products.values.any((product) => product['type'] == 'custom');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Orders (Admin)"), backgroundColor: Colors.indigo),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order['orderId'];
              final userId = order['userId'];
              final status = order['deliveryStatus'] ?? "Placed";
              final products = order['products'] as Map<String, dynamic>;
              final isCustom = isCustomOrder(products);

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Order ID: $orderId", style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (isCustom)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orangeAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Custom Order",
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      Text("User ID: $userId"),
                      Text("Total Amount: ₹${order['totalAmount']}"),
                      const SizedBox(height: 6),
                      const Text("Products:", style: TextStyle(fontWeight: FontWeight.bold)),
                      ...products.entries.map((entry) {
                        final product = entry.value;
                        return ListTile(
                          title: Text(product['name']),
                          subtitle: Text("Product ID: ${entry.key}, Qty: ${product['quantity']}${product['type'] == 'custom' ? ' (Custom)' : ''}"),
                        );
                      }),
                      const SizedBox(height: 10),
                      const Text("Update Delivery Status:", style: TextStyle(fontWeight: FontWeight.bold)),
                      DropdownButton<String>(
                        value: status,
                        items: ['Placed', 'Shipped', 'Delivered'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newStatus) {
                          if (newStatus != null) updateStatus(orderId, newStatus);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}