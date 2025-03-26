import 'package:flutter/material.dart';

class SareesPage extends StatelessWidget {
  const SareesPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> sarees = [
      {
        'name': 'Banarasi Silk Saree',
        'image': 'assets/saree.webp',
        'price': 4500,
        'description':
        'A luxurious Banarasi silk saree with golden zari work. Perfect for weddings and festive occasions.',
        'fabric': 'Pure Silk',
        'origin': 'Varanasi, India'
      },
      {
        'name': 'Kanjivaram Saree',
        'image': 'assets/saree.webp',
        'price': 5000,
        'description':
        'A handwoven Kanjivaram saree with intricate temple border designs.',
        'fabric': 'Silk',
        'origin': 'Tamil Nadu, India'
      },
      {
        'name': 'Chiffon Saree',
        'image': 'assets/saree.webp',
        'price': 1800,
        'description':
        'A lightweight chiffon saree with floral prints, perfect for summer outings.',
        'fabric': 'Chiffon',
        'origin': 'Surat, India'
      },
      {
        'name': 'Cotton Handloom Saree',
        'image': 'assets/saree.webp',
        'price': 2200,
        'description':
        'A breathable cotton handloom saree, best for casual and office wear.',
        'fabric': 'Cotton',
        'origin': 'West Bengal, India'
      },
      {
        'name': 'Georgette Party Saree',
        'image': 'assets/saree.webp',
        'price': 3000,
        'description':
        'A stunning georgette saree with sequins and embroidery, ideal for parties.',
        'fabric': 'Georgette',
        'origin': 'Mumbai, India'
      },
      {
        'name': 'Patola Saree',
        'image': 'assets/saree.webp',
        'price': 5500,
        'description':
        'A rich and vibrant Patola saree with double ikat weaving technique.',
        'fabric': 'Silk',
        'origin': 'Gujarat, India'
      },
      {
        'name': 'Tussar Silk Saree',
        'image': 'assets/saree.webp',
        'price': 4000,
        'description':
        'A natural and eco-friendly Tussar silk saree with earthy tones.',
        'fabric': 'Tussar Silk',
        'origin': 'Bihar, India'
      },
      {
        'name': 'Linen Saree',
        'image': 'assets/saree.webp',
        'price': 2700,
        'description':
        'A simple yet elegant linen saree with minimalistic prints.',
        'fabric': 'Linen',
        'origin': 'Kolkata, India'
      },
      {
        'name': 'Bandhani Saree',
        'image': 'assets/saree.webp',
        'price': 2800,
        'description':
        'A traditional Bandhani saree with tie-dye patterns in vibrant colors.',
        'fabric': 'Cotton & Silk Blend',
        'origin': 'Rajasthan, India'
      },
      {
        'name': 'Bhagalpuri Silk Saree',
        'image': 'assets/saree.webp',
        'price': 3200,
        'description':
        'A lightweight Bhagalpuri silk saree with a unique glossy texture.',
        'fabric': 'Silk',
        'origin': 'Bhagalpur, India'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Sarees Collection")),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: sarees.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SareeDetailPage(saree: sarees[index]),
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
                      sarees[index]['image'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sarees[index]['name'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text("₹${sarees[index]['price']}",
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

class SareeDetailPage extends StatelessWidget {
  final Map<String, dynamic> saree;
  const SareeDetailPage({super.key, required this.saree});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(saree['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                saree['image'],
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              saree['name'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "₹${saree['price']}",
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Text(
              saree['description'],
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Fabric: ${saree['fabric']}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "Origin: ${saree['origin']}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border),
                  label: const Text("Add to Wishlist"),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text("Add to Cart"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
