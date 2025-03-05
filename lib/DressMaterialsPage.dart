import 'package:flutter/material.dart';

class DressMaterialsPage extends StatelessWidget {
  const DressMaterialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> dressMaterials = [
      {
        'name': 'Elegant White Dress Material',
        'image': 'assets/image1.jpg',
        'price': 2500,
        'description':
        'A sophisticated white dress material with intricate embroidery, perfect for special occasions.',
        'fabric': 'Chiffon Blend',
        'origin': 'India'
      },
      {
        'name': 'Casual Checked Dress Material',
        'image': 'assets/image3.jpeg',
        'price': 2800,
        'description':
        'A stylish checked dress material, ideal for casual and semi-formal wear.',
        'fabric': 'Cotton',
        'origin': 'India'
      },
      {
        'name': 'Denim Look Dress Material',
        'image': 'assets/image2.webp',
        'price': 3000,
        'description':
        'A trendy denim-inspired dress material with a modern touch.',
        'fabric': 'Denim Blend',
        'origin': 'India'
      },
      {
        'name': 'Linen Summer Dress Material',
        'image': 'assets/image4.avif',
        'price': 3200,
        'description':
        'A lightweight linen dress material, perfect for warm weather.',
        'fabric': 'Linen',
        'origin': 'India'
      },
      {
        'name': 'Striped Designer Dress Material',
        'image': 'assets/image5.avif',
        'price': 2600,
        'description':
        'A modern striped dress material, suited for office and casual outings.',
        'fabric': 'Cotton',
        'origin': 'India'
      },
      {
        'name': 'Floral Printed Dress Material',
        'image': 'assets/image6.avif',
        'price': 2750,
        'description':
        'A beautiful floral print dress material, great for festive wear.',
        'fabric': 'Rayon',
        'origin': 'India'
      },
      {
        'name': 'Casual Everyday Dress Material',
        'image': 'assets/download.jpeg',
        'price': 2300,
        'description': 'A comfortable everyday dress material, soft and breathable.',
        'fabric': 'Cotton',
        'origin': 'India'
      },
      {
        'name': 'Mandarin Collar Dress Material',
        'image': 'assets/images1.jpeg',
        'price': 2900,
        'description':
        'A chic mandarin collar dress material, adding an elegant appeal.',
        'fabric': 'Cotton Linen Blend',
        'origin': 'India'
      },
      {
        'name': 'Half Sleeve Beach Dress Material',
        'image': 'assets/image1.jpg',
        'price': 2700,
        'description':
        'A lightweight and breezy dress material, ideal for vacations.',
        'fabric': 'Polyester Blend',
        'origin': 'India'
      },
      {
        'name': 'Classic Oxford Dress Material',
        'image': 'assets/image3.jpeg',
        'price': 3100,
        'description': 'A timeless Oxford style dress material with a sophisticated look.',
        'fabric': 'Oxford Cotton',
        'origin': 'India'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Dress Materials Collection")),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: dressMaterials.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DressMaterialDetailPage(dressMaterial: dressMaterials[index]),
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
                      dressMaterials[index]['image'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dressMaterials[index]['name'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text("₹${dressMaterials[index]['price']}",
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

class DressMaterialDetailPage extends StatelessWidget {
  final Map<String, dynamic> dressMaterial;
  const DressMaterialDetailPage({super.key, required this.dressMaterial});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(dressMaterial['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                dressMaterial['image'],
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              dressMaterial['name'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "₹${dressMaterial['price']}",
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Text(
              dressMaterial['description'],
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Fabric: ${dressMaterial['fabric']}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "Origin: ${dressMaterial['origin']}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}