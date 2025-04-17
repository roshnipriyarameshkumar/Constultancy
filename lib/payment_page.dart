import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> address;
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;

  const PaymentPage({
    Key? key,
    required this.address,
    required this.cartItems,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isPlacingOrder = false;

  bool hasCustomProduct() {
    return widget.cartItems.any((item) => item['type'] == 'custom');
  }

  Future<void> placeOrder() async {
    setState(() => isPlacingOrder = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    try {
      final orderId = FirebaseFirestore.instance.collection('orders').doc().id;
      final userId = user.uid;
      final timestamp = DateTime.now();
      final cartIds = widget.cartItems.map((item) => item['cartItemId']).toList();
      final paymentMethod = hasCustomProduct() ? 'Cash on Delivery' : 'Other'; // Enforce COD for custom

      Map<String, dynamic> productMap = {};

      for (var item in widget.cartItems) {
        final productId = item['productId']; // Assuming 'productId' exists for regular products
        final quantityOrdered = int.tryParse(item['quantity'].toString()) ?? 1;
        final price = double.tryParse(item['price'].toString()) ?? 0.0;

        // For custom products, we don't need to check stock
        if (item['type'] != 'custom') {
          final productDoc = await FirebaseFirestore.instance
              .collection('products')
              .doc(productId)
              .get();

          if (!productDoc.exists) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Product ${item['name']} not found.")),
            );
            setState(() => isPlacingOrder = false);
            return;
          }

          final productData = productDoc.data()!;
          final stockQty = int.tryParse(productData['quantity'].toString()) ?? 0;

          if (stockQty < quantityOrdered) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Not enough stock for ${item['name']}.")),
            );
            setState(() => isPlacingOrder = false);
            return;
          }

          await FirebaseFirestore.instance
              .collection('products')
              .doc(productId)
              .update({'quantity': stockQty - quantityOrdered});
        }

        productMap[item['id']] = { // Use cart item ID for custom products as they might not have a 'productId'
          'name': item['name'],
          'description': item['description'],
          'price': price,
          'quantity': quantityOrdered,
          'color': item['color'],
          'imageBase64': item['imageBase64'],
          'type': item['type'],
          if (item['size'] != null) 'size': item['size'],
          if (item['description'] != null) 'customDescription': item['description'], // To avoid conflict with general 'description'
        };
      }

      await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
        'orderId': orderId,
        'userId': userId,
        'address': widget.address,
        'products': productMap,
        'cartIds': cartIds,
        'totalAmount': widget.totalAmount.toStringAsFixed(2),
        'timestamp': timestamp,
        'deliveryStatus': 'Placed',
        'paymentMethod': paymentMethod,
      });

      final cartQuerySnapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: userId)
          .get();

      for (var cartDoc in cartQuerySnapshot.docs) {
        await cartDoc.reference.delete();
      }

      setState(() => isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully! (Cash on Delivery)")),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      setState(() => isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error placing order: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm & Pay"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isPlacingOrder
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Delivery Address",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.address['name'],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${widget.address['address']},\n${widget.address['city']} - ${widget.address['pincode']}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Image.memory(
                        base64Decode(item['imageBase64']),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        "Qty: ${item['quantity']} | ${item['color']}${item['size'] != null ? ' | Size: ${item['size']}' : ''}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: Text("₹${item['price']}", style: const TextStyle(color: Colors.indigo)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Total Amount: ₹${widget.totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.money, color: Colors.white),
                label: Text(
                  hasCustomProduct() ? "Place Order (Cash on Delivery)" : "Place Order",
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}