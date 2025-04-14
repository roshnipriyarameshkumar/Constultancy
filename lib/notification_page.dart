import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to view notifications.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Notifications"),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications found."));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;

              final orderId = data['orderId'] ?? 'N/A';
              final deliveryStatus = data['deliveryStatus'] ?? 'Placed';
              final timestamp = (data['timestamp'] as Timestamp).toDate();
              final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(timestamp);
              final products = (data['products'] as Map<String, dynamic>?) ?? {};

              String notificationMessage;
              switch (deliveryStatus) {
                case 'Shipped':
                  notificationMessage = "Your order has been shipped and is on the way!";
                  break;
                case 'Delivered':
                  notificationMessage = "Your order has been delivered successfully!";
                  break;
                default:
                  notificationMessage = "Your order has been placed and is being processed.";
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Order ID: $orderId", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Order Date: $formattedDate"),
                      const SizedBox(height: 8),
                      Text(notificationMessage, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      const Text("Products:", style: TextStyle(fontWeight: FontWeight.bold)),
                      ...products.entries.map((entry) {
                        final product = entry.value as Map<String, dynamic>;
                        final name = product['name'] ?? 'Unnamed';
                        final quantity = product['quantity'] ?? 1;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(name),
                              Text("Qty: $quantity"),
                            ],
                          ),
                        );
                      }).toList(),
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
