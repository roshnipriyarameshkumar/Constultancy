import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;
  final Map<String, dynamic>? productData;

  const ProductDetailsPage({Key? key, required this.productId, this.productData}) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  Map<String, dynamic>? productData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.productData != null) {
      productData = widget.productData;
      isLoading = false;
    } else {
      fetchProductDetails();
    }
  }

  Future<void> fetchProductDetails() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('products').doc(widget.productId).get();
      if (doc.exists) {
        setState(() {
          productData = doc.data() as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print("Product not found.");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching product details: $e");
    }
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

  Future<void> addToCart() async {
    if (auth.currentUser == null || productData == null) return;

    String userId = auth.currentUser!.uid;
    String productName = productData!['name'] ?? 'Unknown';

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: widget.productId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot existingDoc = snapshot.docs.first;
        int currentQuantity = existingDoc['quantity'] ?? 1;

        await existingDoc.reference.update({
          'quantity': currentQuantity + 1,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item already in cart. Increased quantity."), backgroundColor: Colors.orange),
        );
      } else {
        String cartItemId = FirebaseFirestore.instance.collection('cart').doc().id;
        await FirebaseFirestore.instance.collection('cart').doc(cartItemId).set({
          'cartItemId': cartItemId,
          'productId': widget.productId, // ✅ include productId
          'userId': userId,
          'name': productName,
          'price': productData!['price'] ?? '0.0',
          'description': productData!['description'] ?? '',
          'imageBase64': productData!['imageBase64'] ?? '',
          'color': productData!['color'] ?? 'N/A',
          'quantity': 1,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Added to cart"), backgroundColor: Colors.indigo),
        );
      }
    } catch (e) {
      print("Error adding to cart: $e");
    }
  }

  Future<void> addToWishlist() async {
    if (auth.currentUser == null || productData == null) return;

    String userId = auth.currentUser!.uid;
    String productName = productData!['name'] ?? 'Unknown';

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('wishlist')
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: widget.productId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product already in wishlist"), backgroundColor: Colors.orange),
        );
        return;
      }

      String wishlistItemId = FirebaseFirestore.instance.collection('wishlist').doc().id;
      await FirebaseFirestore.instance.collection('wishlist').doc(wishlistItemId).set({
        'wishlistItemId': wishlistItemId,
        'productId': widget.productId, // ✅ include productId
        'userId': userId,
        'name': productName,
        'price': productData!['price'] ?? '0.0',
        'description': productData!['description'] ?? '',
        'imageBase64': productData!['imageBase64'] ?? '',
        'color': productData!['color'] ?? 'N/A',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to wishlist"), backgroundColor: Colors.indigo),
      );
    } catch (e) {
      print("Error adding to wishlist: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.indigo)),
      );
    }

    if (productData == null) {
      return const Scaffold(
        body: Center(child: Text("Product not found", style: TextStyle(fontSize: 18, color: Colors.red))),
      );
    }

    Uint8List? imageBytes = decodeImage(productData!['imageBase64']);

    return Scaffold(
      appBar: AppBar(
        title: Text(productData!['name'] ?? 'Product Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        elevation: 4.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.indigo, width: 2),
                ),
                child: imageBytes != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.memory(imageBytes, fit: BoxFit.cover),
                )
                    : const Icon(Icons.image, size: 100, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              productData!['name'] ?? 'Unknown',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 8),
            Text(
              "₹${productData!['price'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 8),
            Text(
              "Description: ${productData!['description'] ?? 'No description available.'}",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              "Color: ${productData!['color'] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16, color: Colors.indigo),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: addToCart,
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text("Add to Cart"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,  // Corrected primary to backgroundColor
                    foregroundColor: Colors.white,  // Corrected onPrimary to foregroundColor
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: addToWishlist,
                  icon: const Icon(Icons.favorite),
                  label: const Text("Add to Wishlist"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,  // Corrected primary to backgroundColor
                    foregroundColor: Colors.white,  // Corrected onPrimary to foregroundColor
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
