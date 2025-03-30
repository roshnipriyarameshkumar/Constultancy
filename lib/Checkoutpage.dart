import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ShippingDetailsPage.dart';

class CheckoutPage extends StatelessWidget {
  final double totalAmount;

  CheckoutPage({required this.totalAmount});

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    String userId = auth.currentUser?.uid ?? "";
    if (userId.isEmpty) return Center(child: Text("User not logged in"));

    return Scaffold(
      appBar: AppBar(title: Text("Checkout")),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('cart')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                var cartItems = snapshot.data!.docs;
                if (cartItems.isEmpty) return Center(child: Text("No items in cart"));

                return ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var item = cartItems[index].data() as Map<String, dynamic>;

                    return ListTile(
                      leading: (item['image'] != null && item['image'].toString().isNotEmpty)
                          ? Image.network(item['image'], width: 50, height: 50, fit: BoxFit.cover)
                          : Icon(Icons.image_not_supported, size: 50, color: Colors.grey), // Default placeholder

                      title: Text(item['name'] ?? "No Name"), // Default if null
                      subtitle: Text("₹${item['price']?.toString() ?? '0'}"), // Default price if null
                    );

                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("₹${totalAmount.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShippingDetailsPage(totalAmount: totalAmount)),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: Size(double.infinity, 50)),
                  child: Text("Proceed to Shipping", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
