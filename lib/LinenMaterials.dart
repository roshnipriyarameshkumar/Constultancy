import 'package:flutter/material.dart';

class LinenWearPage extends StatelessWidget {
  const LinenWearPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> linenWear = [
      {
        'name': 'Elegant White Linen Dress',
        'image': 'assets/image1.jpg',
        'price': 2500,
        'description': 'A breathable and soft linen dress, perfect for special occasions.',
        'fabric': 'Pure Linen',
        'origin': 'India'
      },
      {
        'name': 'Casual Linen Checked Shirt & Shorts',
        'image': 'assets/image3.jpeg',
        'price': 2800,
        'description': 'A lightweight linen checked shirt with matching shorts for a relaxed look.',
        'fabric': 'Linen Blend',
        'origin': 'India'
      },
      {
        'name': 'Linen Denim Style Outfit',
        'image': 'assets/image2.webp',
        'price': 3000,
        'description': 'A modern take on denim, crafted from soft linen for ultimate comfort.',
        'fabric': 'Linen Blend',
        'origin': 'India'
      },
      {
        'name': 'Breathable Summer Linen Frock',
        'image': 'assets/image4.avif',
        'price': 3200,
        'description': 'A cool and airy linen frock designed to keep kids fresh in the heat.',
        'fabric': 'Pure Linen',
        'origin': 'India'
      },
      {
        'name': 'Striped Linen T-Shirt & Joggers Set',
        'image': 'assets/image5.avif',
        'price': 2600,
        'description': 'A soft linen striped t-shirt with joggers for effortless comfort.',
        'fabric': 'Linen Blend',
        'origin': 'India'
      },
      {
        'name': 'Floral Printed Linen Dress',
        'image': 'assets/image6.avif',
        'price': 2750,
        'description': 'A charming floral print linen dress for playful elegance.',
        'fabric': 'Linen Blend',
        'origin': 'India'
      },
      {
        'name': 'Everyday Comfortable Linen Outfit',
        'image': 'assets/download.jpeg',
        'price': 2300,
        'description': 'A soft and durable linen outfit for all-day ease.',
        'fabric': 'Pure Linen',
        'origin': 'India'
      },
      {
        'name': 'Mandarin Collar Linen Shirt & Pants',
        'image': 'assets/images1.jpeg',
        'price': 2900,
        'description': 'A classic mandarin collar linen shirt with matching pants for a refined style.',
        'fabric': 'Linen Cotton Blend',
        'origin': 'India'
      },
      {
        'name': 'Linen Half Sleeve Beachwear Set',
        'image': 'assets/image1.jpg',
        'price': 2700,
        'description': 'A breathable and lightweight linen beachwear set, ideal for summer trips.',
        'fabric': 'Linen Blend',
        'origin': 'India'
      },
      {
        'name': 'Classic Oxford Linen Shirt & Shorts',
        'image': 'assets/image3.jpeg',
        'price': 3100,
        'description': 'A premium linen Oxford shirt with shorts for an elegant touch.',
        'fabric': 'Oxford Linen',
        'origin': 'India'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Linen Wear Collection")),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: linenWear.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LinenWearDetailPage(linenWear: linenWear[index]),
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
                      linenWear[index]['image'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          linenWear[index]['name'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text("₹${linenWear[index]['price']}",
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

class LinenWearDetailPage extends StatelessWidget {
  final Map<String, dynamic> linenWear;
  const LinenWearDetailPage({super.key, required this.linenWear});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(linenWear['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                linenWear['image'],
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              linenWear['name'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "₹${linenWear['price']}",
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Text(
              linenWear['description'],
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Fabric: ${linenWear['fabric']}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "Origin: ${linenWear['origin']}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}