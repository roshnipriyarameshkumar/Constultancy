import 'package:flutter/material.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  List<Map<String, dynamic>> wishlistItems = [];

  void addToWishlist(Map<String, dynamic> product) {
    setState(() {
      if (!wishlistItems.any((item) => item['id'] == product['id'])) {
        wishlistItems.add(product);
      }
    });
  }

  void removeFromWishlist(String productId) {
    setState(() {
      wishlistItems.removeWhere((item) => item['id'] == productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wishlist"),
        backgroundColor: Colors.teal,
      ),
      body: wishlistItems.isEmpty
          ? const Center(
        child: Text(
          "Your wishlist is empty",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : ListView.builder(
        itemCount: wishlistItems.length,
        itemBuilder: (context, index) {
          final item = wishlistItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: Image.asset(
                item['image'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(item['title']),
              subtitle: Text(item['description']),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => removeFromWishlist(item['id']),
              ),
            ),
          );
        },
      ),
    );
  }
}
