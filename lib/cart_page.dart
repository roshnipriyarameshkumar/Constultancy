import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:typed_data';

// ✅ Import your homepage file (adjust the path accordingly)
import 'checkout_page.dart';
import 'homepage.dart'; // Replace with correct path

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userId = "";

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid ?? "";
  }

  Future<void> updateQuantity(String cartItemId, int newQuantity, double price) async {
    if (newQuantity > 0) {
      await FirebaseFirestore.instance.collection('cart').doc(cartItemId).update({
        'quantity': newQuantity,
        'totalPrice': price * newQuantity,
      });
    } else {
      await removeFromCart(cartItemId);
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    await FirebaseFirestore.instance.collection('cart').doc(cartItemId).delete();
  }

  Uint8List? decodeImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (e) {
      print("Error decoding image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('cart')
              .where('userId', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            var cartItems = snapshot.data!.docs;
            if (cartItems.isEmpty) {
              return const Center(
                child: Text(
                  "Your cart is empty.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            }

            double totalCost = cartItems.fold(0.0, (sum, doc) {
              final data = doc.data() as Map<String, dynamic>;
              final price = double.tryParse(data['price']?.toString() ?? "0.0") ?? 0.0;
              final quantity = data['quantity'] ?? 1;
              return sum + (price * quantity);
            });

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      var item = cartItems[index];
                      var data = item.data() as Map<String, dynamic>;

                      String productName = data['name'] ?? "Unknown";
                      double price = double.tryParse(data['price']?.toString() ?? "0.0") ?? 0.0;
                      String color = data['color'] ?? "N/A";
                      int quantity = data['quantity'] ?? 1;
                      double itemTotalPrice = price * quantity;
                      Uint8List? imageBytes = decodeImage(data['imageBase64']);

                      return Card(
                        margin: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: imageBytes != null
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(
                                    imageBytes,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                    : const Icon(Icons.image, size: 50, color: Colors.grey),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(productName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text("₹${price.toStringAsFixed(2)}", style: const TextStyle(fontSize: 14, color: Colors.indigo)),
                                    Text("Color: $color", style: const TextStyle(fontSize: 12)),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                                          onPressed: () => updateQuantity(item.id, quantity - 1, price),
                                        ),
                                        Text(quantity.toString(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle, color: Colors.green),
                                          onPressed: () => updateQuantity(item.id, quantity + 1, price),
                                        ),
                                      ],
                                    ),
                                    Text("Total: ₹${itemTotalPrice.toStringAsFixed(2)}",
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal)),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => removeFromCart(item.id),
                                icon: const Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            "₹${totalCost.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CheckoutPage(
                                  cartItems: cartItems.map((doc) {
                                    var data = doc.data() as Map<String, dynamic>;
                                    data['id'] = doc.id; // Include cart item ID
                                    return data;
                                  }).toList(),
                                ),
                              ),
                            );
                          },


                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text("Proceed to Checkout", style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ],
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
