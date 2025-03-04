import 'package:flutter/material.dart';

class BlousesPage extends StatelessWidget {
  const BlousesPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> blouses = [
      {
        'name': 'Elegant White Silk Blouse',
        'image': 'assets/image1.jpg',
        'price': 2500,
        'description': 'A sophisticated white silk blouse, perfect for formal occasions and parties.',
        'fabric': 'Silk Blend',
        'origin': 'India'
      },
      {
        'name': 'Casual Checked Cotton Blouse',
        'image': 'assets/image3.jpeg',
        'price': 2800,
        'description': 'A stylish checked cotton blouse for everyday comfort and casual wear.',
        'fabric': 'Cotton',
        'origin': 'India'
      },
      {
        'name': 'Denim Style Trendy Blouse',
        'image': 'assets/image2.webp',
        'price': 3000,
        'description': 'A modern denim-style blouse for a chic and trendy look.',
        'fabric': 'Denim Blend',
        'origin': 'India'
      },
      {
        'name': 'Linen Summer Blouse',
        'image': 'assets/image4.avif',
        'price': 3200,
        'description': 'A breathable linen blouse, perfect for warm summer days.',
        'fabric': 'Linen',
        'origin': 'India'
      },
      {
        'name': 'Striped Casual Blouse',
        'image': 'assets/image5.avif',
        'price': 2600,
        'description': 'A comfortable striped blouse, ideal for casual outings.',
        'fabric': 'Cotton',
        'origin': 'India'
      },
      {
        'name': 'Floral Printed Blouse',
        'image': 'assets/image6.avif',
        'price': 2750,
        'description': 'A vibrant floral print blouse, adding a feminine touch to your wardrobe.',
        'fabric': 'Rayon',
        'origin': 'India'
      },
      {
        'name': 'Comfortable Everyday Blouse',
        'image': 'assets/download.jpeg',
        'price': 2300,
        'description': 'A soft and cozy blouse for effortless daily wear.',
        'fabric': 'Cotton',
        'origin': 'India'
      },
      {
        'name': 'Mandarin Collar Blouse',
        'image': 'assets/images1.jpeg',
        'price': 2900,
        'description': 'A refined mandarin collar blouse, perfect for an elegant look.',
        'fabric': 'Cotton Linen Blend',
        'origin': 'India'
      },
      {
        'name': 'Half Sleeve Beach Blouse',
        'image': 'assets/image1.jpg',
        'price': 2700,
        'description': 'A lightweight and stylish blouse, ideal for beachside vacations.',
        'fabric': 'Polyester Blend',
        'origin': 'India'
      },
      {
        'name': 'Classic Oxford Blouse',
        'image': 'assets/image3.jpeg',
        'price': 3100,
        'description': 'A timeless Oxford-style blouse for a polished appearance.',
        'fabric': 'Oxford Cotton',
        'origin': 'India'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Blouses Collection")),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: blouses.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlouseDetailPage(blouse: blouses[index]),
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
                      blouses[index]['image'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          blouses[index]['name'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text("₹${blouses[index]['price']}",
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

class BlouseDetailPage extends StatelessWidget {
  final Map<String, dynamic> blouse;
  const BlouseDetailPage({super.key, required this.blouse});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(blouse['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                blouse['image'],
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              blouse['name'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "₹${blouse['price']}",
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Text(
              blouse['description'],
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Fabric: ${blouse['fabric']}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "Origin: ${blouse['origin']}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
