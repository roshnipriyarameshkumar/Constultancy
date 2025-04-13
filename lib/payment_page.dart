import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> address;
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount; // ✅ Total amount passed from AddressPage

  const PaymentPage({
    Key? key,
    required this.address,
    required this.cartItems,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isPlacingOrder = false;

  Future<void> placeOrder() async {
    setState(() => isPlacingOrder = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    try {
      final orderId = FirebaseFirestore.instance.collection('orders').doc().id;
      final userId = user.uid;
      final timestamp = DateTime.now(); // ✅ Using exact DateTime for sorting
      final cartIds = widget.cartItems.map((item) => item['cartItemId']).toList();

      Map<String, dynamic> productMap = {};

      for (var item in widget.cartItems) {
        final productId = item['productId'];
        final quantityOrdered = int.tryParse(item['quantity'].toString()) ?? 1;
        final price = double.tryParse(item['price'].toString()) ?? 0.0;

        // Fetch product data from Firestore to check quantity
        final productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();

        if (!productDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Product ${item['name']} not found.")),
          );
          setState(() => isPlacingOrder = false);
          return;
        }

        final productData = productDoc.data()!;
        final stockQty = int.tryParse(productData['quantity'].toString()) ?? 0;

        if (stockQty < quantityOrdered) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Not enough stock for ${item['name']}.")),
          );
          setState(() => isPlacingOrder = false);
          return;
        }

        // Update stock in products collection
        await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .update({'quantity': stockQty - quantityOrdered});

        // Add to order productMap
        productMap[productId] = {
          'name': item['name'],
          'description': item['description'],
          'price': price,
          'quantity': quantityOrdered,
          'color': item['color'],
          'imageBase64': item['imageBase64'],
        };
      }

      // Save order in Firestore
      await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
        'orderId': orderId,
        'userId': userId,
        'address': widget.address,
        'products': productMap,
        'cartIds': cartIds,
        'totalAmount': widget.totalAmount.toStringAsFixed(2),
        'timestamp': timestamp, // ✅ Save exact DateTime
        'deliveryStatus': 'Placed', // ✅ Initial delivery status
      });

      // Delete cart items
      for (var item in widget.cartItems) {
        final cartItemId = item['cartItemId'];
        await FirebaseFirestore.instance.collection('cart').doc(cartItemId).delete();
      }

      setState(() => isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully!")),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      setState(() => isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error placing order: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm & Pay"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isPlacingOrder
            ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Delivery Address",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              "${widget.address['name']},\n"
                  "${widget.address['address']},\n"
                  "${widget.address['city']} - ${widget.address['pincode']}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text("Order Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text("Qty: ${item['quantity']}"),
                    trailing: Text("₹${item['price']}"),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Total Amount: ₹${widget.totalAmount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text("Place Order"),
                onPressed: placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
