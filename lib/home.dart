import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart, color: Colors.black),
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


            // Promotional Section
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
                                image: AssetImage('assets/WhatsApp Image 2025-01-17 at 17.47.53.jpeg${index + 1}.jpg'),
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
                                  style: const TextStyle(fontSize: 14, color: Colors.indigo),
                                ),
                                const SizedBox(height: 5),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
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

            // Testimonials Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'What Our Customers Say',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: const [
                      Text(
                        '"The best textile store I’ve ever visited! Amazing collection and great prices!"',
                        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('- Happy Customer', style: TextStyle(color: Colors.indigo)),
                      ),
                    ],
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
      ),
    );
  }
}
