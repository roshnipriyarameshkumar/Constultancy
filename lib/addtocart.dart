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
  Future<void> removeFromCart(String productId, bool isCustom) async {
    String userId = auth.currentUser!.uid;
    if (isCustom) {
      // If it's a custom order, remove it from the 'users/{userId}/cart'
      // and potentially from the 'customorder' collection as well,
      // depending on your data model.
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .delete();
      // Consider deleting from 'customorder' if needed:
      // await FirebaseFirestore.instance.collection('customorder').doc(productId).delete();
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .delete();
    }
  }

  /// ✅ Calculate total price
  double calculateTotalCost(List<Map<String, dynamic>> allItems) {
    return allItems.fold(0, (total, item) {
      dynamic price = item['price'];
      if (price == null) {
        price = item['productPrice']; // Fallback for custom orders? Adjust as needed
      }
      if (price is num) {
        return total + price;
      }
      return total;
    });
  }

  /// ✅ Decode base64 image
  Uint8List decodeImage(String? base64String, String? imageUrl) {
    if (base64String != null && base64String.isNotEmpty) {
      try {
        return base64Decode(base64String);
      } catch (e) {
        print('Error decoding base64 image: $e');
        return Uint8List(0);
      }
    }
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Uint8List(0); // Handled by Image.network
    }
    return Uint8List(0);
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: Future.wait([
            FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('cart')
                .get()
                .then((snapshot) => snapshot.docs.map((doc) => doc.data()
              ..addAll({'id': doc.id, 'isCustom': false})).toList()),
            FirebaseFirestore.instance
                .collection('customorder')
                .where('userId', isEqualTo: userId)
                .get()
                .then((snapshot) => snapshot.docs.map((doc) => doc.data()
              ..addAll({'id': doc.id, 'isCustom': true})).toList()),
          ]).then((results) => [...results[0], ...results[1]]),
          builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            var allItems = snapshot.data ?? [];

            return Column(
              children: [
                if (allItems.isEmpty)
                  const Center(
                    child: Text(
                      'Your cart is empty.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: allItems.length,
                      itemBuilder: (context, index) {
                        var item = allItems[index];
                        bool isCustom = item['isCustom'] ?? false;
                        Uint8List imageBytes = decodeImage(item['imageBase64'], item['image']);
                        String productName = item['productName'] ?? item['name'] ?? 'Unknown';
                        dynamic price = item['price'] ?? item['productPrice'];
                        String priceText = price != null ? '₹$price' : '';
                        String subtitleText = '';
                        Widget leadingImage;

                        if (imageBytes.isNotEmpty) {
                          leadingImage = Image.memory(imageBytes, fit: BoxFit.cover, width: 80, height: 80);
                        } else if (item['image'] != null && item['image'].isNotEmpty) {
                          leadingImage = Image.network(item['image'], fit: BoxFit.cover, width: 80, height: 80);
                        } else {
                          leadingImage = Image.network('https://via.placeholder.com/150', width: 80, height: 80, fit: BoxFit.cover);
                        }

                        if (isCustom) {
                          subtitleText += 'Custom Order\n';
                          if (item['size'] != null) subtitleText += 'Size: ${item['size']}\n';
                          if (item['color'] != null) subtitleText += 'Color: ${item['color']}\n';
                          if (item['description'] != null) subtitleText += 'Description: ${item['description']}\n';
                        } else {
                          subtitleText = priceText;
                        }

                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            leading: Stack(
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: leadingImage,
                                ),
                                if (isCustom)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Custom',
                                        style: TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            title: Text(productName),
                            subtitle: Text(subtitleText.trim()),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_shopping_cart, color: Colors.teal),
                              onPressed: () => removeFromCart(item['id'], isCustom),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (allItems.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '₹${calculateTotalCost(allItems)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: allItems.isEmpty ? null : () {
                      for (var item in allItems) {
                        removeFromCart(item['id'], item['isCustom'] ?? false);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Checkout Complete!")));
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