import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var products = snapshot.data!.docs;
          Map<String, List<Map<String, dynamic>>> categorizedProducts = {};

          for (var doc in products) {
            var product = doc.data() as Map<String, dynamic>;
            String category = product['category'] ?? 'Uncategorized';

            if (!categorizedProducts.containsKey(category)) {
              categorizedProducts[category] = [];
            }
            categorizedProducts[category]!.add(product);
          }

          return ListView(
            children: categorizedProducts.entries.map((entry) {
              return ExpansionTile(
                title: Text(entry.key, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                children: entry.value.map((product) {
                  return ListTile(
                    leading: Image.network(
                      product['image'] ?? 'https://via.placeholder.com/150',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(product['name'] ?? 'Unknown'),
                    subtitle: Text('₹${product['price'] ?? '0'}'),
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
