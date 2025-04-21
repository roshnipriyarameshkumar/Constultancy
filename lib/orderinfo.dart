import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderInfoPage extends StatelessWidget {
  const OrderInfoPage({super.key});

  Widget buildTimeline(String status) {
    List<String> stages = ["Placed", "Shipped", "Delivered"];
    int currentStage = stages.indexOf(status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: stages.map((stage) {
        int index = stages.indexOf(stage);
        bool isActive = index <= currentStage;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isActive ? Colors.green : Colors.grey.shade400,
                    child: Icon(
                      isActive ? Icons.check : Icons.radio_button_unchecked,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  if (index < stages.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: currentStage >= index + 1 ? Colors.green : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                stage,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.green : Colors.grey.shade600,
                ),
              ),
            ],
          ),
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("My Orders", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo.shade600,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.indigo));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No orders found.", style: TextStyle(fontSize: 16)),
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
            padding: const EdgeInsets.all(12),
            itemCount: sortedOrders.length,
            itemBuilder: (context, index) {
              final order = sortedOrders[index];
              final data = order.data() as Map<String, dynamic>;
              final status = data['deliveryStatus']?.toString() ?? "Placed";
              final orderId = order.id;
              final totalAmount = data['totalAmount']?.toString() ?? '0';

              final Map<String, dynamic> productsMap =
              (data['products'] as Map<String, dynamic>? ?? {});

              final productList = productsMap.entries.map((entry) {
                final product = entry.value as Map<String, dynamic>;
                return {
                  'name': product['name'] ?? '',
                  'quantity': product['quantity'] ?? 1,
                  'price': product['price']?.toString() ?? '0',
                  'imageBase64': product['imageBase64'] ?? '',
                };
              }).toList();

              return Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text("Order ID: ",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Flexible(
                            child: Text(orderId,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text("Total Amount: ₹$totalAmount",
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500)),
                      const Divider(height: 24),
                      const Text("Products:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 6),
                      ...productList.map((product) {
                        final imageBase64 = product['imageBase64'];
                        Widget imageWidget;

                        if (imageBase64 != null && imageBase64.isNotEmpty) {
                          imageWidget = Image.memory(
                            base64Decode(imageBase64),
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                          );
                        } else {
                          imageWidget = const Icon(Icons.image_not_supported, size: 40);
                        }

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imageWidget,
                          ),
                          title: Text(
                            product['name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text("Qty: ${product['quantity']}"),
                          trailing: Text("₹${product['price']}"),
                        );
                      }).toList(),
                      const SizedBox(height: 12),
                      const Text("Delivery Status:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),
                      buildTimeline(status),
                      const SizedBox(height: 12),
                      if (status == "Placed")
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () => confirmDelete(context, orderId),
                            icon: const Icon(Icons.cancel),
                            label: const Text("Cancel Order"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
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
