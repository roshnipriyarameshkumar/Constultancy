import 'package:flutter/material.dart';

class AddToCartPage extends StatefulWidget {
  const AddToCartPage({super.key});

  @override
  _AddToCartPageState createState() => _AddToCartPageState();
}

class _AddToCartPageState extends State<AddToCartPage> {
  // List to store cart items
  List<Map<String, dynamic>> cartItems = [
    {"name": "Product 1", "price": 500, "image": 'assets/images1.jpeg'},
    {"name": "Product 2", "price": 1000, "image": 'assets/image1.jpg'},
    // Add more products dynamically if needed
  ];

  // Function to remove item from the cart
  void removeFromCart(int index) {
    setState(() {
      cartItems.removeAt(index); // Remove item from the cart
    });
  }

  // Calculate the total cost of all items in the cart
  double calculateTotalCost() {
    return cartItems.fold(0, (total, item) => total + item["price"]);
  }

  // Function to proceed to checkout (you can implement your checkout logic here)
  void proceedToCheckout() {
    if (cartItems.isNotEmpty) {
      // Navigate to the checkout page or perform further checkout actions
      // For now, we just show a simple dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Proceeding to Checkout'),
            content: Text('Total: ₹${calculateTotalCost()}'),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    cartItems.clear(); // Clear the cart after checkout
                  });
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
    // Calculate total price
    double totalPrice = calculateTotalCost();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Cart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // If the cart is empty, show a message
            if (cartItems.isEmpty)
              const Center(
                child: Text(
                  'Your cart is empty.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
            else
            // Cart items list (dynamic)
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length, // Display dynamic cart items
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Image.asset(item['image'], width: 80, height: 80, fit: BoxFit.cover),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                Text('₹${item['price']}', style: const TextStyle(fontSize: 14, color: Colors.teal)),
                              ],
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => removeFromCart(index),
                              icon: const Icon(Icons.remove_shopping_cart, color: Colors.teal),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Cart Total
            if (cartItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('₹$totalPrice', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                  ],
                ),
              ),

            // Checkout Button
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: cartItems.isEmpty ? null : () => proceedToCheckout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Proceed to Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
