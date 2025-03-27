import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddToCartPage extends StatefulWidget {
  const AddToCartPage({super.key});

  @override
  _AddToCartPageState createState() => _AddToCartPageState();
}

class _AddToCartPageState extends State<AddToCartPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = auth.currentUser!.uid;
  }

  // Function to remove item from the cart in Firestore
  Future<void> removeFromCart(String productId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  // Function to calculate total cost
  double calculateTotalCost(List<DocumentSnapshot> cartItems) {
    return cartItems.fold(0, (total, item) => total + (item['price'] as num));
  }

  // Function to proceed to checkout
  void proceedToCheckout(List<DocumentSnapshot> cartItems) {
    if (cartItems.isNotEmpty) {
      double total = calculateTotalCost(cartItems);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Proceeding to Checkout'),
            content: Text('Total: ₹$total'),
            actions: [
              TextButton(
                onPressed: () async {
                  // Clear cart after checkout
                  for (var item in cartItems) {
                    await removeFromCart(item.id);
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Cart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('cart')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            var cartItems = snapshot.data!.docs;

            return Column(
              children: [
                if (cartItems.isEmpty)
                  const Center(
                    child: Text(
                      'Your cart is empty.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        var item = cartItems[index];
                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Image.network(
                                  item['image'] ?? 'https://via.placeholder.com/150',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'] ?? 'Unknown',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '₹${item['price']}',
                                      style: const TextStyle(fontSize: 14, color: Colors.teal),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                IconButton(
                                  onPressed: () => removeFromCart(item.id),
                                  icon: const Icon(Icons.remove_shopping_cart, color: Colors.teal),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                if (cartItems.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '₹${calculateTotalCost(cartItems)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                      ],
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: cartItems.isEmpty ? null : () => proceedToCheckout(cartItems),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Proceed to Checkout'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
