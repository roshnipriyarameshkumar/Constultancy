import 'package:flutter/material.dart';

class ShirtsPage extends StatelessWidget {
  const ShirtsPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> shirts = [
      {
        'name': 'Formal White Shirt',
        'image': 'assets/image1.jpg',
        'price': 1500,
        'description':
        'A classic formal white shirt with a crisp collar, perfect for office wear.',
        'fabric': 'Cotton Blend',
        'origin': 'India'
      },
      {
        'name': 'Checked Casual Shirt',
        'image': 'assets/image3.jpeg',
        'price': 1800,
        'description':
        'A stylish checked shirt, great for casual outings and weekend getaways.',
        'fabric': 'Cotton',
        'origin': 'India'
      },
      {
        'name': 'Denim Shirt',
        'image': 'assets/image2.webp',
        'price': 2000,
        'description':
        'A rugged denim shirt with a classic button-down style.',
        'fabric': 'Denim',
        'origin': 'India'
      },
      {
        'name': 'Linen Summer Shirt',
        'image': 'assets/image4.avif',
        'price': 2200,
        'description':
        'A breathable linen shirt, ideal for hot summer days.',
        'fabric': 'Linen',
        'origin': 'India'
      },
      {
        'name': 'Striped Office Shirt',
        'image': 'assets/image5.avif',
        'price': 1600,
        'description':
        'A professional striped shirt, perfect for meetings and business events.',
        'fabric': 'Cotton',
        'origin': 'India'
      },
      {
        'name': 'Floral Printed Shirt',
        'image': 'assets/image6.avif',
        'price': 1750,
        'description':
        'A trendy floral printed shirt, great for vacations and parties.',
        'fabric': 'Rayon',
        'origin': 'India'
      },
      {
        'name': 'Casual Polo Shirt',
        'image': 'assets/download.jpeg',
        'price': 1300,
        'description': 'A comfortable polo shirt for everyday casual wear.',
        'fabric': 'Cotton',
        'origin': 'India'
      },
      {
        'name': 'Mandarin Collar Shirt',
        'image': 'assets/images1.jpeg',
        'price': 1900,
        'description':
        'A modern mandarin collar shirt, adding a touch of sophistication.',
        'fabric': 'Cotton Linen Blend',
        'origin': 'India'
      },
      {
        'name': 'Half Sleeve Beach Shirt',
        'image': 'assets/image1.jpg',
        'price': 1700,
        'description':
        'A lightweight half sleeve shirt, perfect for beach vacations.',
        'fabric': 'Polyester Blend',
        'origin': 'India'
      },
      {
        'name': 'Oxford Classic Shirt',
        'image': 'assets/image3.jpeg',
        'price': 2100,
        'description': 'A timeless Oxford shirt with a refined fit and look.',
        'fabric': 'Oxford Cotton',
        'origin': 'India'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Shirts Collection")),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: shirts.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShirtDetailPage(shirt: shirts[index]),
                ),
              );
            },
            child: Card(
              elevation: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Image.asset(
                      shirts[index]['image'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shirts[index]['name'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text("₹${shirts[index]['price']}",
                            style: const TextStyle(
                                fontSize: 14, color: Colors.green)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.favorite_border),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_shopping_cart),
                              onPressed: () {},
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
        },
      ),
    );
  }
}

class ShirtDetailPage extends StatelessWidget {
  final Map<String, dynamic> shirt;
  const ShirtDetailPage({super.key, required this.shirt});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(shirt['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                shirt['image'],
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              shirt['name'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "₹${shirt['price']}",
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Text(
              shirt['description'],
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Fabric: ${shirt['fabric']}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "Origin: ${shirt['origin']}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
