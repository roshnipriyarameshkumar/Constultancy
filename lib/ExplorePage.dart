import 'package:flutter/material.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> exploreItems = [
      {
        'title': 'Linen Fabrics Collection',
        'image': 'assets/download.jpeg',
        'description': 'Experience the finest 100% pure linen materials, perfect for all occasions.',
      },
      {
        'title': 'Ethnic Wear',
        'image': 'assets/image1.jpg',
        'description': 'Handpicked linen sarees, kurtas, and dresses designed with intricate weaves and modern styles.',
      },
      {
        'title': 'Casual & Formal Attire',
        'image': 'assets/image3.jpeg',
        'description': 'Explore linen shirts, suits, and dresses for a luxurious yet breathable feel.',
      },
      {
        'title': 'Custom Designs',
        'image': 'assets/image4.avif',
        'description': 'Get tailor-made linen outfits suited to your style and preference.',
      },
      {
        'title': 'Home Decor Linens',
        'image': 'assets/images1.jpeg',
        'description': 'Discover linen curtains, cushions, and tablecloths for a premium home setup.',
      },
      {
        'title': 'Eco-Friendly Linen',
        'image': 'assets/images1.jpeg',
        'description': 'Sustainable linen products crafted with love for the environment.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore Amsam Tex"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: exploreItems.map((item) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                      child: Image.asset(
                        item['image'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item['description'],
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // Handle navigation or action
                              },
                              child: const Text(
                                "Discover More",
                                style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
