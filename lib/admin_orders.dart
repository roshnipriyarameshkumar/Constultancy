import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  // Function to update delivery status in Firestore
  void updateStatus(String orderId, String newStatus) {
    FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'deliveryStatus': newStatus,
    });
  }

  // Function to check if the order has custom products
  bool isCustomOrder(Map<String, dynamic> products) {
    return products.values.any((product) => product['type'] == 'custom');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Orders (Admin)"),
        backgroundColor: Colors.indigo,
      ),
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
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
                        children: [
                          Expanded( // Make Order ID text take available space
                            child: Text(
                              "Order ID: $orderId",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.indigo,
                              ),
                            ),
                          ),
                          if (isCustom)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0), // Add some spacing
                              child: Container(
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
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text("User ID: $userId", style: TextStyle(color: Colors.grey[700])),
                      Text("Total Amount: ₹${order['totalAmount']}", style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      const Text("Products:", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      ...products.entries.map((entry) {
                        final product = entry.value;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(product['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          subtitle: Text(
                            "Product ID: ${entry.key}, Qty: ${product['quantity']}${product['type'] == 'custom' ? ' (Custom)' : ''}",
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                          leading: Icon(
                            Icons.shopping_bag,
                            color: Colors.indigo,
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      const Text("Update Delivery Status:", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: status,
                        isExpanded: true,
                        items: ['Placed', 'Shipped', 'Delivered'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(fontSize: 16, color: Colors.indigo),
                            ),
                          );
                        }).toList(),
                        onChanged: (newStatus) {
                          if (newStatus != null) updateStatus(orderId, newStatus);
                        },
                        dropdownColor: Colors.white,
                        icon: Icon(Icons.arrow_drop_down, color: Colors.indigo),
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