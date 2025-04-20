import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Order History'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.indigo));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders found."));
          }

          final userOrders = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            return data['userId'] == userId && data['deliveryStatus'] != null;
          }).toList();

          final activeOrders = userOrders.where((order) {
            final status = order['deliveryStatus'];
            return status == 'Placed' || status == 'Shipped';
          }).toList();

          final pastOrders = userOrders.where((order) {
            final status = order['deliveryStatus'];
            return status == 'Delivered';
          }).toList();

          if (activeOrders.isEmpty && pastOrders.isEmpty) {
            return const Center(child: Text("You haven't placed any orders yet."));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activeOrders.isNotEmpty) ...[
                    const Text(
                      'Active Orders',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activeOrders.length,
                      itemBuilder: (context, index) => _buildOrderCard(activeOrders[index]),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (pastOrders.isNotEmpty) ...[
                    const Text(
                      'Past Orders (Delivered)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: pastOrders.length,
                      itemBuilder: (context, index) => _buildOrderCard(pastOrders[index]),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(DocumentSnapshot order) {
    final data = order.data() as Map<String, dynamic>? ?? {};

    final orderId = data['orderId'] ?? 'Unknown';
    final status = data['deliveryStatus'] ?? 'Unknown';
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy – hh:mm a').format(timestamp);
    final totalAmount = data['totalAmount'] ?? 0;
    final products = data['products'] as Map<String, dynamic>? ?? {};

    Color statusColor;
    switch (status) {
      case 'Placed':
        statusColor = Colors.blue;
        break;
      case 'Shipped':
        statusColor = Colors.orange;
        break;
      case 'Delivered':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order #$orderId',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(status, style: const TextStyle(color: Colors.white)),
                  backgroundColor: statusColor,
                )
              ],
            ),
            const SizedBox(height: 5),
            Text('Ordered on: $formattedDate'),
            const Divider(height: 20),

            // Product list
            if (products.isNotEmpty)
              Column(
                children: products.entries.map((entry) {
                  final product = entry.value as Map<String, dynamic>? ?? {};
                  final name = product['name'] ?? 'No Name';
                  final price = (product['price'] as num?) ?? 0;
                  final qty = (product['quantity'] as num?) ?? 0;
                  final img64 = product['imageBase64'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: img64 != null
                              ? Image.memory(
                            base64Decode(img64),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                              : const Icon(Icons.image_not_supported, size: 50),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text('Quantity: $qty'),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '₹${price * qty}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            else
              const Text("No product details found.", style: TextStyle(color: Colors.red)),

            const Divider(height: 20),

            // Total
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Total: ₹$totalAmount',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
