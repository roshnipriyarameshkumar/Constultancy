import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  ProductDetailsPage({required this.productId, required this.productData});

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading = false;

  Future<void> addToCart() async {
    User? user = auth.currentUser;
    if (user == null) {
      print("User not logged in");
      return;
    }

    String userId = user.uid;
    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(widget.productId)
          .set({
        ...widget.productData,
        'quantity': 1,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Product added to cart successfully");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added to Cart")));
    } catch (e) {
      print("Error adding to cart: $e");
    }

    setState(() => isLoading = false);
  }

  Future<void> addToWishlist() async {
    User? user = auth.currentUser;
    if (user == null) {
      print("User not logged in");
      return;
    }

    String userId = user.uid;
    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc(widget.productId)
          .set({
        ...widget.productData,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Product added to wishlist successfully");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Added to Wishlist")));
    } catch (e) {
      print("Error adding to wishlist: $e");
    }

    setState(() => isLoading = false);
  }

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
    Uint8List imageBytes = decodeImage(widget.productData['image']);

    return Scaffold(
      appBar: AppBar(title: Text(widget.productData['name'] ?? 'Product Details')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: imageBytes.isNotEmpty
                    ? DecorationImage(image: MemoryImage(imageBytes), fit: BoxFit.cover)
                    : null,
                color: Colors.grey[200],
              ),
              child: imageBytes.isEmpty ? Center(child: Text("No Image Available")) : null,
            ),
            SizedBox(height: 20),
            Text(
              widget.productData['name'] ?? "Unknown Product",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "₹${widget.productData['price'] ?? '0'}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 10),
            Text(
              widget.productData['description'] ?? "No description available",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: addToCart,
                  icon: Icon(Icons.shopping_cart),
                  label: Text("Add to Cart"),
                ),
                ElevatedButton.icon(
                  onPressed: addToWishlist,
                  icon: Icon(Icons.favorite),
                  label: Text("Wishlist"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
