import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistPage extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    String userId = auth.currentUser?.uid ?? "";
    if (userId.isEmpty) return Center(child: Text("User not logged in"));

    return Scaffold(
      appBar: AppBar(title: Text("My Wishlist")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('wishlist')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var wishlistItems = snapshot.data!.docs;
          if (wishlistItems.isEmpty) return Center(child: Text("No items in wishlist"));

          return ListView.builder(
            itemCount: wishlistItems.length,
            itemBuilder: (context, index) {
              var item = wishlistItems[index].data() as Map<String, dynamic>;

              // Ensure price is a double
              double price = 0.0;
              if (item['price'] is num) {
                price = (item['price'] as num).toDouble();
              } else if (item['price'] is String) {
                price = double.tryParse(item['price']) ?? 0.0;
              }

              return ListTile(
                title: Text(item['name'] ?? "No Name"),
                subtitle: Text("₹${price.toStringAsFixed(2)}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.shopping_cart, color: Colors.green),
                      onPressed: () => moveToCart(userId, wishlistItems[index].id, item),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removeFromWishlist(userId, wishlistItems[index].id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Function to move item from wishlist to cart
  void moveToCart(String userId, String wishlistItemId, Map<String, dynamic> item) async {
    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .add(item); // Add item to cart

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc(wishlistItemId)
          .delete(); // Remove from wishlist

      print("Item moved to cart successfully.");
    } catch (e) {
      print("Error moving item to cart: $e");
    }
  }

  // Function to remove item from wishlist
  void removeFromWishlist(String userId, String wishlistItemId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc(wishlistItemId)
          .delete(); // Remove item

      print("Item removed from wishlist.");
    } catch (e) {
      print("Error removing item from wishlist: $e");
    }
  }
}
