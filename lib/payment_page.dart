import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;
  final Map<String, dynamic> address;

  const PaymentPage({
    Key? key,
    required this.cartItems,
    required this.totalAmount,
    required this.address,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isPlacingOrder = false;

  Future<void> placeOrder() async {
    setState(() => isPlacingOrder = true);
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in.");

      final orderId = FirebaseFirestore.instance.collection('orders').doc().id;
      final Map<String, dynamic> orderedProducts = {};
      List<String> skippedItems = [];

      for (final item in widget.cartItems) {
        final productId = item['productId']?.toString();
        final requestedQuantity = item['quantity'] is int
            ? item['quantity']
            : int.tryParse(item['quantity']?.toString() ?? '');
        final cartId = item['cartId']?.toString();

        if (productId == null || productId.isEmpty || requestedQuantity == null) {
          skippedItems.add("Invalid item in cart: Missing productId or quantity.");
          continue;
        }

        // 🔄 Re-fetch product from Firestore
        final productSnapshot = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();

        if (!productSnapshot.exists) {
          skippedItems.add("Product $productId does not exist.");
          continue;
        }

        final productData = productSnapshot.data()!;
        final name = productData['name'] ?? 'Unnamed';
        final availableQty = productData['quantity'] ?? 0;
        final price = productData['price'] ?? 0.0;
        final imageBase64 = productData['imageBase64'] ?? '';

        if (availableQty < requestedQuantity) {
          skippedItems.add("Not enough stock for $name. Available: $availableQty");
          continue;
        }

        // ✅ Add to order map
        orderedProducts[productId] = {
          'productId': productId,
          'name': name,
          'quantity': requestedQuantity,
          'price': price,
          'imageBase64': imageBase64,
        };

        // 🔽 Reduce quantity in products collection
        final productRef = FirebaseFirestore.instance.collection('products').doc(productId);
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(productRef);
          if (snapshot.exists) {
            final currentQty = snapshot['quantity'] ?? 0;
            final updatedQty = (currentQty - requestedQuantity).clamp(0, currentQty);
            transaction.update(productRef, {'quantity': updatedQty});
          }
        });

        // 🗑️ Remove from cart
        if (cartId != null && cartId.isNotEmpty) {
          await FirebaseFirestore.instance.collection('cart').doc(cartId).delete();
        }
      }

      if (orderedProducts.isEmpty) {
        throw Exception("No valid items to order.\n${skippedItems.join('\n')}");
      }

      await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
        'orderId': orderId,
        'userId': userId,
        'address': widget.address,
        'products': orderedProducts,
        'totalAmount': widget.totalAmount,
        'timestamp': Timestamp.now(),
      });

      _showSuccessDialog(skippedItems);
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => isPlacingOrder = false);
    }
  }

  void _showErrorDialog(String errorMsg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.indigo.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("❌ Order Failed", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
        content: Text("Failed to place order:\n$errorMsg", style: const TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Retry", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(List<String> skippedItems) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.indigo.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("🎉 Order Placed!", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your order has been placed successfully.",
                style: TextStyle(color: Colors.black87)),
            if (skippedItems.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text("⚠️ Some items were skipped:", style: TextStyle(fontWeight: FontWeight.bold)),
              ...skippedItems.map((msg) => Text("• $msg", style: const TextStyle(fontSize: 14))),
            ]
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text("Go Home", style: TextStyle(color: Colors.indigo)),
          ),
        ],
      ),
    );
  }

  String _formatAddress(Map<String, dynamic> address) {
    return "${address['name'] ?? ''},\n${address['address'] ?? ''},\n${address['city'] ?? ''} - ${address['pincode'] ?? ''}";
  }

  @override
  Widget build(BuildContext context) {
    final formattedAddress = _formatAddress(widget.address);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Confirm Payment", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildStepIndicator(step: 3),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Shipping Address",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.indigo.shade100),
                    ),
                    child: Text(formattedAddress, style: const TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
                  Text("Total Amount: ₹${widget.totalAmount.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  const Spacer(),
                  isPlacingOrder
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                      label: const Text("Place Order", style: TextStyle(color: Colors.white, fontSize: 16)),
                      onPressed: placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({required int step}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _stepItem("BAG", step == 1),
          _divider(),
          _stepItem("ADDRESS", step == 2),
          _divider(),
          _stepItem("PAYMENT", step == 3),
        ],
      ),
    );
  }

  Widget _stepItem(String label, bool isActive) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: isActive ? Colors.indigo : Colors.grey,
      ),
    );
  }

  Widget _divider() {
    return const Text("———", style: TextStyle(color: Colors.grey));
  }
}
