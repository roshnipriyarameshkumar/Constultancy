import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'signup.dart'; // Import the signup page
import 'addtocart.dart';
import 'profile.dart';
import 'SareesPage.dart';
import 'ShirtsPage.dart';
import 'DressMaterialsPage.dart';
import 'KidswearPage.dart';
import 'BlousePage.dart';
import 'LinenMaterials.dart';


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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddToCartPage()),
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
                MaterialPageRoute(builder: (context) => const SignupPage()),
              );
            },
            icon: const Icon(Icons.login, color: Colors.black),
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
                'Amsam Textiles',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Shop'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Wishlist'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          color: Colors.indigo[50],
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                6,
                    (index) => GestureDetector(
                  onTap: () {
                    // Navigate to respective pages
                    switch (index) {
                      case 0:
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SareesPage()));
                        break;
                      case 1:
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ShirtsPage()));
                        break;
                      case 2:
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DressMaterialsPage()));
                        break;
                      case 3:
                        Navigator.push(context, MaterialPageRoute(builder: (context) => KidsWearPage()));
                        break;
                      case 4:
                        Navigator.push(context, MaterialPageRoute(builder: (context) => BlousesPage()));
                        break;
                      case 5:
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LinenWearPage()));
                        break;
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage([
                            'assets/download.jpeg',
                            'assets/download.jpeg',
                            'assets/download.jpeg',
                            'assets/download.jpeg',
                            'assets/download.jpeg',
                            'assets/download.jpeg'
                          ][index]),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          [
                            'Sarees',
                            'Shirts',
                            'Dress Materials',
                            'Kids Wear',
                            'Blouses',
                            'Linen'
                          ][index],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

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
                  height: 100,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
              ),
            ),
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
                                image: AssetImage(
                                  [
                                    'assets/download.jpeg',
                                    'assets/image1.jpg',
                                    'assets/image2.webp',
                                  ][index],
                                ),
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
                                image: AssetImage([
                                  'assets/images1.jpeg', // Image 1
                                  'assets/image2.webp', // Image 2
                                  'assets/download.jpeg', // Image 3
                                ][index]), // Get image based on index
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
            )
            ,
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }
        },
      ),
    );
  }
}
