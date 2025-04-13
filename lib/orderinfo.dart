import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderInfoPage extends StatelessWidget {
  const OrderInfoPage({super.key});

  Widget buildTimeline(String status) {
    List<String> stages = ["Placed", "Shipped", "Delivered"];
    int currentStage = stages.indexOf(status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stages.map((stage) {
        int index = stages.indexOf(stage);
        return Column(
          children: [
            Icon(
              index <= currentStage ? Icons.check_circle : Icons.radio_button_unchecked,
              color: index <= currentStage ? Colors.green : Colors.grey,
              size: 30,
            ),
            const SizedBox(height: 4),
            Text(
              stage,
              style: TextStyle(
                color: index <= currentStage ? Colors.green : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Future<void> deleteOrder(BuildContext context, String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order cancelled successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cancelling order: $e")),
      );
    }
  }

  void confirmDelete(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel Order"),
        content: const Text("Are you sure you want to cancel this order?"),
        actions: [
          TextButton(
            child: const Text("No"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(context);
              await deleteOrder(context, orderId);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view your orders.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.indigo,
      appBar: AppBar(
        title: const Text("My Orders", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No orders found.", style: TextStyle(color: Colors.white, fontSize: 16)),
            );
          }

          final orders = snapshot.data!.docs;
          final sortedOrders = orders.toList()
            ..sort((a, b) {
              final at = a['timestamp'];
              final bt = b['timestamp'];
              if (at == null || bt == null) return 0;
              return (bt as Timestamp).compareTo(at as Timestamp);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: sortedOrders.length,
            itemBuilder: (context, index) {
              final order = sortedOrders[index];
              final data = order.data() as Map<String, dynamic>;
              final status = data['deliveryStatus']?.toString() ?? "Placed";
              final orderId = order.id;

              final Map<String, dynamic> productsMap =
              (data['products'] as Map<String, dynamic>? ?? {});

              final productList = productsMap.entries.map((entry) {
                final product = entry.value as Map<String, dynamic>;
                return {
                  'name': product['name'] ?? '',
                  'quantity': product['quantity'] ?? 1,
                  'price': product['price']?.toString() ?? '0',
                };
              }).toList();

              final totalAmount = data['totalAmount']?.toString() ?? '0';

              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Order ID: $orderId", style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text("Total: ₹$totalAmount", style: const TextStyle(fontSize: 16)),
                      const Divider(height: 20, thickness: 1),
                      const Text("Products:", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      ...productList.map((product) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(product['name'])),
                              Text("Qty: ${product['quantity']}"),
                              Text("₹${product['price']}"),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 12),
                      const Text("Delivery Status:", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      buildTimeline(status),
                      const SizedBox(height: 12),
                      if (status == "Placed")
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () => confirmDelete(context, orderId),
                            icon: const Icon(Icons.cancel, color: Colors.white),
                            label: const Text("Cancel Order", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
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
