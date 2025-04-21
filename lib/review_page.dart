import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewPage extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> products;

  const ReviewPage({
    super.key,
    required this.orderId,
    required this.products,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Map<String, TextEditingController> _reviewControllers = {};
  final Map<String, double> _ratings = {};
  final Map<String, bool> _expandedStates = {};
  final Map<String, bool> _submittedStates = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers, ratings and states for each product
    for (var productId in widget.products.keys) {
      _reviewControllers[productId] = TextEditingController();
      _ratings[productId] = 0.0;
      _expandedStates[productId] = false;
      _submittedStates[productId] = false;
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _reviewControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitReview(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final reviewText = _reviewControllers[productId]!.text.trim();
    final rating = _ratings[productId]!;

    if (rating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a star rating')),
      );
      return;
    }

    try {
      // Create review document in 'reviews' collection
      await _firestore.collection('reviews').add({
        'userId': user.uid,
        'orderId': widget.orderId,
        'productId': productId,
        'productName': widget.products[productId]['name'],
        'rating': rating,
        'review': reviewText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update the UI to show review was submitted
      setState(() {
        _submittedStates[productId] = true;
        _expandedStates[productId] = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting review: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Reviews'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: widget.products.entries.map((entry) {
            final productId = entry.key;
            final product = entry.value as Map<String, dynamic>;
            final productName = product['name'] ?? 'Unknown Product';
            final isExpanded = _expandedStates[productId] ?? false;
            final isSubmitted = _submittedStates[productId] ?? false;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (!isSubmitted)
                          IconButton(
                            icon: Icon(
                              isExpanded ? Icons.close : Icons.add,
                              color: isExpanded ? Colors.red : Colors.indigo,
                            ),
                            onPressed: isExpanded
                                ? () {
                              setState(() {
                                _expandedStates[productId] = false;
                                _reviewControllers[productId]!.clear();
                                _ratings[productId] = 0.0;
                              });
                            }
                                : () {
                              setState(() {
                                _expandedStates[productId] = true;
                              });
                            },
                          )
                        else
                          const Icon(Icons.check_circle, color: Colors.green),
                      ],
                    ),
                    if (isExpanded) ...[
                      const SizedBox(height: 16),
                      Center(
                        child: RatingBar.builder(
                          initialRating: _ratings[productId]!,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            setState(() {
                              _ratings[productId] = rating;
                            });
                          },
                        ),

                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _reviewControllers[productId],
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Your review',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _submitReview(productId),
                          child: const Text(
                            'Submit Review',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

