// YOUR EXISTING IMPORTS
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cart_page.dart';
import 'notification_page.dart';
import 'offers_page.dart';
import 'profile.dart';
import 'wishlist_page.dart';
import 'login.dart';
import 'ProductDetailsPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  List<Map<String, dynamic>> _filteredProducts = [];

  final List<Widget> _pages = [
    Container(),
    WishlistPage(),
    CartPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
    );
  }

  Uint8List _convertBase64ToImage(String base64String) {
    try {
      if (base64String.contains(',')) {
        base64String = base64String.split(',').last;
      }
      return base64Decode(base64String);
    } catch (e) {
      print('Error converting base64 to image: $e');
      return Uint8List(0);
    }
  }

  @override
  void initState() {
    super.initState();
    _pages[0] = _buildHomePageBody();
  }

  Widget _buildHomePageBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: CarouselSlider(
              items: [
                'assets/image4.jpeg',
                'assets/images1.jpeg',
                'assets/images1.jpeg',
                'assets/image4.jpeg'
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
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Trending Products',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          _filteredProducts.isNotEmpty
              ? _buildGridFromList(_filteredProducts)
              : StreamBuilder<QuerySnapshot>(
            stream:
            FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              var products = snapshot.data!.docs;
              return _buildGridFromSnapshot(products);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGridFromList(List<Map<String, dynamic>> productList) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: productList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        var product = productList[index];
        Uint8List imageBytes = _convertBase64ToImage(product['imageBase64'] ?? '');
        return _buildProductCard(product, product['productId'], imageBytes);
      },
    );
  }

  Widget _buildGridFromSnapshot(List<QueryDocumentSnapshot> products) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        var product = products[index].data() as Map<String, dynamic>;
        String productId = products[index].id;
        Uint8List imageBytes = _convertBase64ToImage(product['imageBase64'] ?? '');
        return _buildProductCard(product, productId, imageBytes);
      },
    );
  }

  Widget _buildProductCard(
      Map<String, dynamic> product, String productId, Uint8List imageBytes) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              productId: productId,
              productData: product,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: Colors.grey[200],
                image: DecorationImage(
                  image: imageBytes.isNotEmpty
                      ? MemoryImage(imageBytes)
                      : const AssetImage('assets/default_product.jpg')
                  as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '₹${product['price'] ?? '0'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.black),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.arrow_upward),
                          title: const Text('Price: Low to High'),
                          onTap: () async {
                            Navigator.pop(context);
                            QuerySnapshot snapshot = await FirebaseFirestore
                                .instance
                                .collection('products')
                                .get();
                            List<Map<String, dynamic>> sortedList = snapshot.docs
                                .map((doc) {
                              final data =
                              doc.data() as Map<String, dynamic>;
                              data['productId'] = doc.id;
                              return data;
                            })
                                .toList();
                            sortedList.sort((a, b) =>
                                (int.tryParse(a['price'].toString()) ?? 0)
                                    .compareTo(
                                    int.tryParse(b['price'].toString()) ??
                                        0));
                            setState(() {
                              _filteredProducts = sortedList;
                            });
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.arrow_downward),
                          title: const Text('Price: High to Low'),
                          onTap: () async {
                            Navigator.pop(context);
                            QuerySnapshot snapshot = await FirebaseFirestore
                                .instance
                                .collection('products')
                                .get();
                            List<Map<String, dynamic>> sortedList = snapshot.docs
                                .map((doc) {
                              final data =
                              doc.data() as Map<String, dynamic>;
                              data['productId'] = doc.id;
                              return data;
                            })
                                .toList();
                            sortedList.sort((a, b) =>
                                (int.tryParse(b['price'].toString()) ?? 0)
                                    .compareTo(
                                    int.tryParse(a['price'].toString()) ??
                                        0));
                            setState(() {
                              _filteredProducts = sortedList;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Search textiles, sarees...',
                          style: TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.local_offer, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  OffersPage()),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outlined), label: 'Wishlist'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
