import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddToCartPage extends StatefulWidget {
  const AddToCartPage({super.key});

  @override
  _AddToCartPageState createState() => _AddToCartPageState();
}

class _AddToCartPageState extends State<AddToCartPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  /// ✅ Remove item from cart
  Future<void> removeFromCart(String productId) async {
    String userId = auth.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('cart')
        .doc(userId)
        .collection('items')
        .doc(productId)
        .delete();
  }

  /// ✅ Calculate total price
  double calculateTotalCost(List<DocumentSnapshot> cartItems) {
    return cartItems.fold(0, (total, item) => total + (item['price'] as num));
  }

  /// ✅ Decode base64 image
  Uint8List decodeImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return Uint8List(0);
    try {
      return base64Decode(base64String);
    } catch (e) {
      print('Error decoding image: $e');
      return Uint8List(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    String userId = auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Your Cart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('cart')
              .doc(userId)
              .collection('items')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var cartItems = snapshot.data!.docs;

            return Column(
              children: [
                if (cartItems.isEmpty)
                  const Center(
                    child: Text(
                      'Your cart is empty.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        var item = cartItems[index];
                        Uint8List imageBytes = decodeImage(item['image']);

                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            leading: imageBytes.isNotEmpty
                                ? Image.memory(imageBytes, width: 80, height: 80, fit: BoxFit.cover)
                                : Image.network('https://via.placeholder.com/150', width: 80, height: 80, fit: BoxFit.cover),
                            title: Text(item['name'] ?? 'Unknown'),
                            subtitle: Text('₹${item['price']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_shopping_cart, color: Colors.teal),
                              onPressed: () => removeFromCart(item.id),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (cartItems.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '₹${calculateTotalCost(cartItems)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: cartItems.isEmpty ? null : () {
                      for (var item in cartItems) {
                        removeFromCart(item.id);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Checkout Complete!")));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Proceed to Checkout'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
