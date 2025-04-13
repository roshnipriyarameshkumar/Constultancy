import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text("Order Notifications"), backgroundColor: Colors.indigo),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderId = order['orderId'];
              final deliveryStatus = order['deliveryStatus'] ?? "Placed";
              final timestamp = order['timestamp'].toDate();
              final products = order['products'] as Map<String, dynamic>;

              // Determine the notification message based on delivery status
              String notificationMessage = "";
              if (deliveryStatus == 'Placed') {
                notificationMessage = "Your order has been placed and is being processed.";
              } else if (deliveryStatus == 'Shipped') {
                notificationMessage = "Your order has been shipped and is on the way!";
              } else if (deliveryStatus == 'Delivered') {
                notificationMessage = "Your order has been delivered successfully!";
              }

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Order ID: $orderId", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Order Date: ${timestamp.toLocal().toString()}"),
                      const SizedBox(height: 6),
                      Text(notificationMessage, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text("Products:", style: TextStyle(fontWeight: FontWeight.bold)),
                      ...products.entries.map((entry) {
                        final product = entry.value;
                        return ListTile(
                          title: Text(product['name']),
                          subtitle: Text("Qty: ${product['quantity']}"),
                        );
                      }),
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
