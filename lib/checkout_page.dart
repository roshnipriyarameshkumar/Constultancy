import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'address_page.dart';

class CheckoutPage extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;

  const CheckoutPage({Key? key, required this.cartItems}) : super(key: key);

  double getTotal() {
    return cartItems.fold(0.0, (sum, item) {
      final price = double.tryParse(item['price'].toString()) ?? 0.0;
      final quantity = int.tryParse(item['quantity'].toString()) ?? 1;
      return sum + (price * quantity);
    });
  }

  Uint8List? decodeImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      return base64Decode(base64String);
    } catch (e) {
      print("Error decoding image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text("Checkout", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildStepIndicator(step: 1),
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemBuilder: (context, index) {
                final item = cartItems[index];
                final name = item['name'] ?? '';
                final price = double.tryParse(item['price'].toString()) ?? 0;
                final quantity = int.tryParse(item['quantity'].toString()) ?? 1;
                final total = price * quantity;
                final imageBytes = decodeImage(item['imageBase64']);

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: imageBytes != null
                              ? Image.memory(
                            imageBytes,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          )
                              : Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.image, size: 30),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87)),
                              const SizedBox(height: 4),
                              Text("Qty: $quantity",
                                  style: const TextStyle(color: Colors.black54)),
                              const SizedBox(height: 2),
                              Text("Price: ₹${price.toStringAsFixed(2)}",
                                  style: const TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                        Text(
                          "₹${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    "Total: ₹${getTotal().toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddressPage(
                            cartItems: cartItems,
                            totalAmount: getTotal(),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Proceed to Address",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
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
