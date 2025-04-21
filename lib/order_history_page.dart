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
        title: const Text('Order History'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No orders found."));
          }

          // Filter & sort delivered orders
          final deliveredOrders = snapshot.data!.docs
              .where((doc) {
            final data = doc.data() as Map<String, dynamic>? ?? {};
            final status = data['deliveryStatus'] as String?;
            final products = data['products'];
            return status == 'Delivered' &&
                products is Map<String, dynamic> &&
                products.isNotEmpty;
          })
              .toList()
            ..sort((a, b) {
              final aTime = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
              final bTime = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
              return bTime.compareTo(aTime); // Sort descending
            });

          if (deliveredOrders.isEmpty) {
            return const Center(child: Text("No delivered orders found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: deliveredOrders.length,
            itemBuilder: (context, index) =>
                _buildOrderCard(deliveredOrders[index]),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(DocumentSnapshot order) {
    final data = order.data() as Map<String, dynamic>? ?? {};

    final orderId = data['orderId'] ?? 'Unknown';
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy – hh:mm a').format(timestamp);
    final totalAmountRaw = data['totalAmount'] ?? 0;
    final totalAmount = (double.tryParse(totalAmountRaw.toString()) ?? 0.0).toStringAsFixed(2);

    final products = data['products'] as Map<String, dynamic>? ?? {};

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      color: Colors.indigo.shade50,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with order ID and checkmark
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Order #$orderId',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.indigo,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.check_circle, color: Colors.green, size: 24)
              ],
            ),
            const SizedBox(height: 5),
            Text('Delivered on: $formattedDate'),
            const Divider(height: 20),

            // Product List
            Column(
              children: products.entries.map((entry) {
                final product = entry.value as Map<String, dynamic>? ?? {};
                final name = product['name'] ?? 'No Name';
                final priceRaw = product['price'];
                final qtyRaw = product['quantity'];
                final price = (double.tryParse(priceRaw.toString()) ?? 0.0);
                final qty = (int.tryParse(qtyRaw.toString()) ?? 0);
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
                        '₹${(price * qty).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const Divider(height: 20),

            // Total Amount
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'Total: ₹$totalAmount',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
