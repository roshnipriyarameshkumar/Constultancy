import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'CheckoutPage.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  double calculateTotal(List<QueryDocumentSnapshot> cartItems) {
    double total = 0.0;
    for (var item in cartItems) {
      var data = item.data() as Map<String, dynamic>;
      double price = (data['price'] is num)
          ? (data['price'] as num).toDouble()
          : double.tryParse(data['price']?.toString() ?? '0') ?? 0.0;

      int quantity = (data['quantity'] is int) ? data['quantity'] : 1;
      total += price * quantity;
    }
    return total;
  }

  void updateQuantity(String userId, String docId, int newQuantity) {
    if (newQuantity > 0) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(docId)
          .update({'quantity': newQuantity});
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(docId)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = auth.currentUser;
    if (user == null) return Center(child: Text("User not logged in"));

    return Scaffold(
      appBar: AppBar(title: Text("My Cart")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var cartItems = snapshot.data!.docs;
          if (cartItems.isEmpty) return Center(child: Text("No items in cart"));

          double totalAmount = calculateTotal(cartItems);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    var item = cartItems[index].data() as Map<String, dynamic>;

                    double price = (item['price'] is num)
                        ? (item['price'] as num).toDouble()
                        : double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;

                    int quantity = (item['quantity'] is int) ? item['quantity'] : 1;

                    return ListTile(
                      leading: item['image'] != null
                          ? Image.network(item['image'], width: 50, height: 50, fit: BoxFit.cover)
                          : Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      title: Text(item['name'] ?? "No Name"),
                      subtitle: Text("₹${(price * quantity).toStringAsFixed(2)}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, color: Colors.red),
                            onPressed: () {
                              updateQuantity(user.uid, cartItems[index].id, quantity - 1);
                            },
                          ),
                          Text(quantity.toString(), style: TextStyle(fontSize: 16)),
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.green),
                            onPressed: () {
                              updateQuantity(user.uid, cartItems[index].id, quantity + 1);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
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
                      onPressed: cartItems.isNotEmpty ? () => proceedToCheckout(totalAmount) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cartItems.isNotEmpty ? Colors.indigo : Colors.grey,
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text("Proceed to Checkout", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void proceedToCheckout(double totalAmount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(totalAmount: totalAmount),
      ),
    );
  }
}
