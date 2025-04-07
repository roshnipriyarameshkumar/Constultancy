import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'OrderConfirmationPage.dart';

class PaymentPage extends StatelessWidget {
  final String orderId;
  final double totalAmount;
  final List<Map<String, dynamic>> cartItems;
  final String name;  // Added name parameter
  final String address;  // Added address p, required, required String address String namearameter

  // Constructor to accept parameters
  PaymentPage({
    required this.orderId,
    required this.totalAmount,
    required this.cartItems,
    required this.name,
    required this.address,
  });

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> processPayment(BuildContext context) async {
    String userId = auth.currentUser?.uid ?? "";
    if (userId.isEmpty) return;

    try {
      // Simulate successful payment update in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .update({
        'status': 'Paid',
        'paymentMethod': 'Online Payment',
      });

      // Reduce stock quantity for ordered products
      for (var item in cartItems) {
        String productId = item['productId'];
        int quantityOrdered = item['quantity'];

        DocumentReference productRef = FirebaseFirestore.instance.collection('products').doc(productId);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(productRef);
          if (snapshot.exists) {
            int currentStock = snapshot['quantity'] ?? 0;
            int newStock = currentStock - quantityOrdered;
            if (newStock >= 0) {
              transaction.update(productRef, {'quantity': newStock});
            }
          }
        });
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationPage(
            orderId: orderId,
            totalAmount: totalAmount,
            name: name,
            address: address,
          ),
        ),
      );
    } catch (e) {
      print("Error processing payment: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment failed. Try again.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => processPayment(context),
          child: Text("Complete Payment"),
        ),
      ),
    );
  }
}
