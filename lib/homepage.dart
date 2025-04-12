import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'addtocart.dart';
import 'profile.dart';
import 'ExplorePage.dart';
import 'NotificationPage.dart';
import 'WishlistPage.dart';
import 'CategoriesPage.dart';
import 'login.dart';

/// Top-level helper function to decode a base64 string and optionally decrypt it.
/// For demonstration, decryption is done with a simple XOR using key 0xAA.
Uint8List decodeAndDecryptImage(String? base64String, {bool decrypt = false}) {
  if (base64String == null || base64String.isEmpty) {
    return Uint8List(0);
  }
  try {
    // Decode the base64 string.
    Uint8List bytes = base64Decode(base64String);
    if (decrypt) {
      final int key = 0xAA; // Dummy XOR key for demonstration.
      Uint8List decrypted = Uint8List(bytes.length);
      for (int i = 0; i < bytes.length; i++) {
        decrypted[i] = bytes[i] ^ key;
      }
      return decrypted;
    }
    return bytes;
  } catch (e) {
    print('Error decoding image: $e');
    return Uint8List(0);
  }
}

/// Top-level helper function to encrypt image bytes using a simple XOR with key 0xAA.
/// This encryption is reversible and provided only for demonstration.
Uint8List encryptImage(Uint8List imageBytes) {
  final int key = 0xAA;
  Uint8List encrypted = Uint8List(imageBytes.length);
  for (int i = 0; i < imageBytes.length; i++) {
    encrypted[i] = imageBytes[i] ^ key;
  }
  return encrypted;
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Main pages of your application.
  final List<Widget> _pages = [
    HomePageBody(),
    ExplorePage(),
    CategoriesPage(),
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
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
      // Floating action button redirects to the custom order page.
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.build),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CustomOrderPage()),
          );
        },
      ),
    );
  }
}

class HomePageBody extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;

  /// Returns an image widget by decoding the base64 image stored in Firestore.
  /// For custom orders, the image is stored in the 'design' field (with decryption);
  /// for regular products, it is stored in the 'imageBase64' field.
  Widget getProductImage(String? imageData, {bool isCustomOrder = false}) {
    if (imageData == null || imageData.isEmpty) {
      return const Center(child: Icon(Icons.image_not_supported));
    }
    // If the string is an asset reference:
    if (imageData.startsWith('assets/')) {
      return Image.asset(imageData, fit: BoxFit.cover);
    }
    try {
      // For regular products, no decryption is needed.
      Uint8List imageBytes = decodeAndDecryptImage(imageData, decrypt: isCustomOrder);
      return Image.memory(imageBytes, fit: BoxFit.cover);
    } catch (e) {
      return const Center(child: Icon(Icons.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carousel displaying asset images.
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: CarouselSlider(
              items: ['assets/image1.jpg', 'assets/image2.jpg', 'assets/image3.jpg', 'assets/image4.jpg']
                  .map((image) {
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
              options: CarouselOptions(height: 150, autoPlay: true, enlargeCenterPage: true),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Trending Products',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // StreamBuilder to fetch products from Firestore.
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              // Declare products locally from the snapshot data.
              final products = snapshot.data!.docs;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index].data() as Map<String, dynamic>;
                  String productId = products[index].id;
                  bool isCustomOrder = product['customOrder'] == true;
                  // For custom orders, use the 'design' field with decryption;
                  // for regular products, use the 'imageBase64' field.
                  Uint8List imageBytes = isCustomOrder
                      ? decodeAndDecryptImage(product['design'], decrypt: true)
                      : decodeAndDecryptImage(product['imageBase64'], decrypt: false);

                  return InkWell(
                    onTap: () {
                      // Navigate to ProductDetailsPage when a product is tapped.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsPage(
                            productId: productId,
                            product: product,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 120,
                            child: imageBytes.isNotEmpty
                                ? Image.memory(imageBytes, fit: BoxFit.cover)
                                : const Center(child: CircularProgressIndicator()),
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
                                  '₹${product['price'] ?? '0'}',
                                  style: const TextStyle(fontSize: 14, color: Colors.indigo),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProductDetailsPage extends StatelessWidget {
  final String productId;
  final Map<String, dynamic> product;

  const ProductDetailsPage({Key? key, required this.productId, required this.product}) : super(key: key);

  /// Returns an image widget by decoding the base64 image.
  /// For custom orders, it uses the 'design' field; otherwise, it uses the 'imageBase64' field.
  Widget getProductImage(String? imageData, {bool isCustomOrder = false}) {
    if (imageData == null || imageData.isEmpty) {
      return const Center(child: Icon(Icons.image_not_supported));
    }
    if (imageData.startsWith('assets/')) {
      return Image.asset(imageData, fit: BoxFit.cover);
    }
    try {
      Uint8List imageBytes = decodeAndDecryptImage(imageData, decrypt: isCustomOrder);
      return Image.memory(imageBytes, fit: BoxFit.cover);
    } catch (e) {
      return const Center(child: Icon(Icons.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCustomOrder = product['customOrder'] == true;
    return Scaffold(
      appBar: AppBar(
        title: Text(product['name'] ?? 'Product Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: isCustomOrder
                  ? getProductImage(product['design'], isCustomOrder: true)
                  : getProductImage(product['imageBase64'], isCustomOrder: false),
            ),
            const SizedBox(height: 16),
            Text(
              product['name'] ?? 'Unknown',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Price: ₹${product['price'] ?? '0'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(product['description'] ?? 'No description available.'),
          ],
        ),
      ),
    );
  }
}

class CustomOrderPage extends StatefulWidget {
  const CustomOrderPage({Key? key}) : super(key: key);

  @override
  _CustomOrderPageState createState() => _CustomOrderPageState();
}

class _CustomOrderPageState extends State<CustomOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  Uint8List? _designImageBytes;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickDesignImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _designImageBytes = imageBytes;
      });
    }
  }

  Uint8List encryptAndCompressImage(Uint8List imageBytes) {
    // Encrypt the image using the helper function.
    return encryptImage(imageBytes);
  }

  Future<void> _submitCustomOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_designImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a design image.')),
      );
      return;
    }

    // Encrypt the design image.
    Uint8List encryptedImage = encryptAndCompressImage(_designImageBytes!);

    // Prepare custom order data.
    Map<String, dynamic> customOrderData = {
      'productName': _productNameController.text,
      'description': _descriptionController.text,
      'size': _sizeController.text,
      'quantity': _quantityController.text,
      'color': _colorController.text,
      // Store the encrypted image as a base64-encoded string.
      'design': base64Encode(encryptedImage),
      'customOrder': true,
      'timestamp': FieldValue.serverTimestamp(),
    };

    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .add(customOrderData);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Custom order added to cart!')),
    );
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _sizeController.dispose();
    _quantityController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Order'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Customize Your Product',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a product name'
                    : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a description'
                    : null,
              ),
              TextFormField(
                controller: _sizeController,
                decoration: const InputDecoration(labelText: 'Size'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a size'
                    : null,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter quantity' : null,
              ),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a color' : null,
              ),
              const SizedBox(height: 16),
              _designImageBytes != null
                  ? Image.memory(_designImageBytes!, height: 150)
                  : const Text('No design image selected.'),
              ElevatedButton(
                onPressed: _pickDesignImage,
                child: const Text('Upload Design'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitCustomOrder,
                child: const Text('Submit Custom Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
