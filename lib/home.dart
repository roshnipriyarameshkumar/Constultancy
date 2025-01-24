import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'signup.dart'; // Import the signup page
import 'addtocart.dart';
import 'profile.dart';
void main() {
  runApp(const TextileStoreApp());
}

class TextileStoreApp extends StatelessWidget {
  const TextileStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Amsam Tex Store',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: const TextTheme(bodyMedium: TextStyle(fontFamily: 'Poppins')),
      ),
      home: const HomePage(),
      routes: {
        '/signup': (context) => const SignupPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
              // Navigate to cart page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddToCartPage()), // Navigate to SignUpPage
              );
            },
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
          ),
          IconButton(
            onPressed: () {
              // Show notifications
            },
            icon: const Icon(Icons.notifications, color: Colors.black),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignupPage()), // Navigate to SignUpPage
              );
            },
            icon: const Icon(Icons.login, color: Colors.black), // Login icon
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: const Text(
                'Amsam Tex Store',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Shop'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Wishlist'),
              onTap: () {
                // Navigate to Wishlist Page
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.location_on, color: Colors.black54),
                      SizedBox(width: 5),
                      Text('No Location Found', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Enter Location', style: TextStyle(color: Colors.indigo)),
                  ),
                ],
              ),
            ),

            // Categories Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              color: Colors.indigo[50],
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    6,
                        (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.indigo[100],
                            child: const Icon(Icons.category, size: 30, color: Colors.indigo),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            ['Sarees', 'Shirts', 'Dress Materials', 'Kids Wear', 'Blouses', 'Linen'][index],
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Carousel Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: CarouselSlider(
                items: [
                  'assets/images1.jpeg',
                  'assets/images1.jpeg',
                  'assets/images1.jpeg',
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
                  height: 200,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
              ),
            ),

            // Clearance Sale and Offers Section
            Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                color: Colors.indigo[50],
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: const [
                      Icon(Icons.local_offer, color: Colors.indigo, size: 30),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Flat 50% Off on Sarees - Limited Time Offer!',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Best Selling Products Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Best Selling Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  3,
                      (index) => Card(
                    margin: const EdgeInsets.all(10),
                    child: SizedBox(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/WhatsApp Image 2025-01-17 at 17.47.53.jpeg'),
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
                                  'Best Seller ${index + 1}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '₹${(index + 1) * 500}',
                                  style: const TextStyle(fontSize: 14, color: Colors.indigo),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => addToCart('Best Seller ${index + 1}'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigo,
                                        minimumSize: const Size(70, 30),
                                      ),
                                      child: const Text('Add to Cart'),
                                    ),
                                    IconButton(
                                      onPressed: () => addToWishlist('Best Seller ${index + 1}'),
                                      icon: Icon(
                                        wishlist.contains('Best Seller ${index + 1}') ? Icons.favorite : Icons.favorite_border,
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
                  ),
                ),
              ),
            ),

            // Highly Rated Products Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Highly Rated Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  3,
                      (index) => Card(
                    margin: const EdgeInsets.all(10),
                    child: SizedBox(
                      width: 150,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/WhatsApp Image 2025-01-17 at 17.47.53.jpeg'),
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
                                  'Highly Rated ${index + 1}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '₹${(index + 1) * 700}',
                                  style: const TextStyle(fontSize: 14, color: Colors.indigo),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => addToCart('Highly Rated ${index + 1}'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigo,
                                        minimumSize: const Size(70, 30),
                                      ),
                                      child: const Text('Add to Cart'),
                                    ),
                                    IconButton(
                                      onPressed: () => addToWishlist('Highly Rated ${index + 1}'),
                                      icon: Icon(
                                        wishlist.contains('Highly Rated ${index + 1}') ? Icons.favorite : Icons.favorite_border,
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
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()), // Navigate to ProfilePage
              );
            }
            // If needed, you can handle other tabs here (Home, Shop, Wishlist).
          },
        ),

    );
  }
}
