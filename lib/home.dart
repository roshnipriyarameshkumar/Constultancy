import 'package:flutter/material.dart';
import 'addtocart.dart'; // Import AddToCartPage

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 1,
        title: TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.teal[50],
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
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Sign Out') {
                Navigator.pushReplacementNamed(context, '/login');
              } else if (value == 'Account Management') {
                Navigator.pushNamed(context, '/signup');
              }
            },
            icon: const Icon(Icons.more_vert, color: Colors.black),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Sign Out',
                child: Text('Sign Out'),
              ),
              const PopupMenuItem(
                value: 'Account Management',
                child: Text('Account Management'),
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
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
              onTap: () {},
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
                      Icon(Icons.location_on, color: Colors.teal),
                      SizedBox(width: 5),
                      Text('No Location Found', style: TextStyle(color: Colors.teal)),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Enter Location', style: TextStyle(color: Colors.teal)),
                  ),
                ],
              ),
            ),

            // Categories Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              color: Colors.teal[50],
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
                            child: const Icon(Icons.category, size: 30, color: Colors.teal),
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

            // Featured Products Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Featured Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  5,
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
                                image: AssetImage('assets/product${index + 1}.jpg'), // Replace with actual image paths
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
                                  'Product ${index + 1}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '₹${(index + 1) * 500}',
                                  style: const TextStyle(fontSize: 14, color: Colors.teal),
                                ),
                                const SizedBox(height: 5),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const AddToCartPage()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    minimumSize: const Size(double.infinity, 30),
                                  ),
                                  child: const Text('Add to Cart'),
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
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
