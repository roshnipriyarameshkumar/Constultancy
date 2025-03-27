import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'addtocart.dart';
import 'profile.dart';
import 'ExplorePage.dart';
import 'NotificationPage.dart';
import 'WishlistPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> wishlist = [];
  List<String> cart = [];

  void addToWishlist(String product) {
    setState(() {
      if (!wishlist.contains(product)) {
        wishlist.add(product);
      }
    });
  }

  void addToCart(String product) {
    setState(() {
      cart.add(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search textiles, sarees...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddToCartPage()),
              );
            },
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
            icon: const Icon(Icons.notifications, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: CarouselSlider(
                items: [
                  'assets/image3.jpeg',
                  'assets/image4.avif',
                  'assets/image5.avif',
                  'assets/image6.avif'
                ].map((image) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 150,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Latest Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var products = snapshot.data!.docs;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: products.map((doc) {
                      var product = doc.data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: SizedBox(
                          width: 160,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(product['image'] ?? 'https://via.placeholder.com/150'),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'] ?? 'Unknown',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      product['description'] ?? 'No description available',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Size: ${product['size'] ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      'Color: ${product['color'] ?? 'N/A'}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      '₹${product['price'] ?? '0'}',
                                      style: const TextStyle(fontSize: 14, color: Colors.indigo),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => addToCart(product['name'] ?? 'Unknown'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.indigo,
                                            minimumSize: const Size(70, 30),
                                          ),
                                          child: const Text('Add'),
                                        ),
                                        IconButton(
                                          onPressed: () => addToWishlist(product['name'] ?? 'Unknown'),
                                          icon: Icon(
                                            wishlist.contains(product['name']) ? Icons.favorite : Icons.favorite_border,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
