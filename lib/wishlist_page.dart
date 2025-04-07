import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homepage.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  String userId = "";

  @override
  void initState() {
    super.initState();
    userId = auth.currentUser!.uid;
  }

  Future<void> removeFromWishlist(String wishlistItemId) async {
    await FirebaseFirestore.instance.collection('wishlist').doc(wishlistItemId).delete();
  }

  Future<void> moveToCart(String wishlistItemId, Map<String, dynamic> productData) async {
    final cartRef = FirebaseFirestore.instance.collection('cart');
    final productName = productData['name'];

    final existing = await cartRef
        .where('userId', isEqualTo: userId)
        .where('name', isEqualTo: productName)
        .get();

    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      final currentQty = doc['quantity'] ?? 1;
      await cartRef.doc(doc.id).update({'quantity': currentQty + 1});
    } else {
      final cartItem = Map<String, dynamic>.from(productData);
      cartItem['userId'] = userId;
      cartItem['quantity'] = 1;
      await cartRef.add(cartItem);
    }

    await removeFromWishlist(wishlistItemId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${productData['name']} moved to cart.'),
        backgroundColor: Colors.teal,
      ),
    );
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
        title: const Text('Wishlist', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('wishlist')
              .where('userId', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            var wishlistItems = snapshot.data!.docs;
            if (wishlistItems.isEmpty) {
              return const Center(
                child: Text('Your wishlist is empty.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              );
            }

            return ListView.builder(
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                var item = wishlistItems[index];
                var data = item.data() as Map<String, dynamic>;

                String productName = data['name'] ?? "Unknown";
                double price = double.tryParse(data['price']?.toString() ?? "0.0") ?? 0.0;
                String color = data['color'] ?? "N/A";
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
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shopping_cart, color: Colors.teal),
                              onPressed: () => moveToCart(item.id, data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeFromWishlist(item.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
