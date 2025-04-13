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

      Map<String, dynamic> productMap = {};

      for (var item in widget.cartItems) {
        final productId = item['productId'];
        final quantityOrdered = int.tryParse(item['quantity'].toString()) ?? 1;
        final price = double.tryParse(item['price'].toString()) ?? 0.0;

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

        productMap[productId] = {
          'name': item['name'],
          'description': item['description'],
          'price': price,
          'quantity': quantityOrdered,
          'color': item['color'],
          'imageBase64': item['imageBase64'],
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
        const SnackBar(content: Text("Order placed successfully!")),
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
                      subtitle: Text("Qty: ${item['quantity']} | ${item['color']}", style: const TextStyle(color: Colors.grey)),
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
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: const Text("Place Order", style: TextStyle(color: Colors.white)),
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
