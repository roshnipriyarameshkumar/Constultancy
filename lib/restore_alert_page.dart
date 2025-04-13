import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestoreAlertPage extends StatelessWidget {
  const RestoreAlertPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Restore Alerts', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No products available.',
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          final lowStockProducts = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final quantity = data['quantity'];
            return quantity != null && quantity is int && quantity <= 5;
          }).toList();

          if (lowStockProducts.isEmpty) {
            return const Center(
              child: Text(
                'All products have sufficient stock.',
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lowStockProducts.length,
            itemBuilder: (context, index) {
              final product = lowStockProducts[index];
              final data = product.data() as Map<String, dynamic>;
              final productName = data['name'] ?? 'Unnamed Product';
              final productId = product.id;
              final quantity = data['quantity'] ?? 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.redAccent),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 36),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Low Stock Alert',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[800],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Product: $productName',
                            style: const TextStyle(color: Colors.black87),
                          ),
                          Text(
                            'Product ID: $productId',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          Text(
                            'Only $quantity left in stock. Please restock soon!',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
