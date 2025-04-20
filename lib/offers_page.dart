import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OffersPage extends StatefulWidget {
  @override
  _OffersPageState createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {
  final Map<String, String> _productNameCache = {};

  Future<List<String>> _fetchProductNames(List<dynamic> productIds) async {
    List<String> productNames = [];

    // Firestore 'in' queries are limited to 10 items
    const int batchSize = 10;
    for (int i = 0; i < productIds.length; i += batchSize) {
      final batchIds = productIds
          .sublist(i, i + batchSize > productIds.length ? productIds.length : i + batchSize)
          .cast<String>();

      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where(FieldPath.documentId, whereIn: batchIds)
          .get();

      for (var doc in querySnapshot.docs) {
        final name = doc['name'] ?? 'Unnamed Product';
        _productNameCache[doc.id] = name;
        productNames.add(name);
      }
    }

    return productNames;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text("🔥 Today's Offers", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('offers')
            .orderBy('startDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(child: Text("No active offers at the moment!", style: TextStyle(fontSize: 16)));

          final offers = snapshot.data!.docs.where((doc) {
            final start = (doc['startDate'] as Timestamp).toDate();
            final end = (doc['endDate'] as Timestamp).toDate();
            return now.isAfter(start) && now.isBefore(end);
          }).toList();

          if (offers.isEmpty)
            return const Center(child: Text("No current offers available.", style: TextStyle(fontSize: 16)));

          return ListView.builder(
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              final title = offer['offerTitle'] ?? 'Untitled Offer';
              final description = offer['offerDescription'] ?? 'No description available.';
              final startDate = (offer['startDate'] as Timestamp).toDate();
              final endDate = (offer['endDate'] as Timestamp).toDate();

              final List<dynamic>? productIds = offer['applicableProductIds'];

              return FutureBuilder<List<String>>(
                future: productIds != null && productIds.isNotEmpty
                    ? _fetchProductNames(productIds)
                    : Future.value([]),
                builder: (context, snapshot) {
                  final productNames = snapshot.data ?? [];
                  final applicableText = productIds == null || productIds.isEmpty
                      ? "Applicable on all products"
                      : productNames.isNotEmpty
                      ? "Applicable on: ${productNames.join(', ')}"
                      : "Applicable on selected products";

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 6,
                      shadowColor: Colors.deepPurpleAccent.withOpacity(0.2),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.local_offer_rounded, color: Colors.indigo),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.shopping_bag_outlined, size: 20, color: Colors.grey),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    applicableText,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  "Valid from ${DateFormat.yMMMd().format(startDate)} to ${DateFormat.yMMMd().format(endDate)}",
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
