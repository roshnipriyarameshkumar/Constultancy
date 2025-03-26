import 'package:flutter/material.dart';

class KidsWearPage extends StatelessWidget {
  const KidsWearPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> kidsWear = [
      {
        'name': 'Adorable White Party Dress',
        'image': 'assets/kids.webp',
        'price': 2500,
        'description': 'A charming white dress perfect for birthday parties and festive occasions.',
        'fabric': 'Chiffon Blend',
        'origin': 'India'
      },
      {
        'name': 'Casual Checked Shirt & Shorts',
        'image': 'assets/kids.webp',
        'price': 2800,
        'description': 'A trendy checked shirt with matching shorts, ideal for casual outings.',
        'fabric': 'Cotton',
        'origin': 'India'
      },
      {
        'name': 'Denim Style Kids Outfit',
        'image': 'assets/kids.webp',
        'price': 3000,
        'description': 'A stylish denim-inspired outfit, designed for a cool and modern look.',
        'fabric': 'Denim Blend',
        'origin': 'India'
      },
      {
        'name': 'Linen Summer Frock',
        'image': 'assets/kids.webp',
        'price': 3200,
        'description': 'A breathable linen frock, keeping kids comfy during summer.',
        'fabric': 'Linen',
        'origin': 'India'
      },
      {
        'name': 'Striped T-Shirt & Joggers Set',
        'image': 'assets/kids.webp',
        'price': 2600,
        'description': 'A sporty striped t-shirt with joggers for active kids.',
        'fabric': 'Cotton',
        'origin': 'India'
      },
      {
        'name': 'Floral Printed Kids Dress',
        'image': 'assets/kids.webp',
        'price': 2750,
        'description': 'A cute floral print dress, perfect for casual and festive occasions.',
        'fabric': 'Rayon',
        'origin': 'India'
      },
      {
        'name': 'Comfortable Everyday Outfit',
        'image': 'assets/kids.webp',
        'price': 2300,
        'description': 'A soft and cozy everyday outfit for playful kids.',
        'fabric': 'Cotton',
        'origin': 'India'
      },
      {
        'name': 'Mandarin Collar Shirt & Pants',
        'image': 'assets/kids.webp',
        'price': 2900,
        'description': 'A stylish mandarin collar shirt with matching pants for a smart look.',
        'fabric': 'Cotton Linen Blend',
        'origin': 'India'
      },
      {
        'name': 'Half Sleeve Beachwear Set',
        'image': 'assets/kids.webp',
        'price': 2700,
        'description': 'A lightweight and breathable beachwear set for summer vacations.',
        'fabric': 'Polyester Blend',
        'origin': 'India'
      },
      {
        'name': 'Classic Oxford Shirt & Shorts',
        'image': 'assets/kids.webp',
        'price': 3100,
        'description': 'A formal Oxford shirt with shorts for a sophisticated touch.',
        'fabric': 'Oxford Cotton',
        'origin': 'India'
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Kids Wear Collection")),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: kidsWear.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KidsWearDetailPage(kidsWear: kidsWear[index]),
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
                      kidsWear[index]['image'],
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kidsWear[index]['name'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text("₹${kidsWear[index]['price']}",
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

class KidsWearDetailPage extends StatelessWidget {
  final Map<String, dynamic> kidsWear;
  const KidsWearDetailPage({super.key, required this.kidsWear});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kidsWear['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                kidsWear['image'],
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              kidsWear['name'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              "₹${kidsWear['price']}",
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Text(
              kidsWear['description'],
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Fabric: ${kidsWear['fabric']}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              "Origin: ${kidsWear['origin']}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
