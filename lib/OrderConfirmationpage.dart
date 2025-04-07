import 'package:flutter/material.dart';

class OrderConfirmationPage extends StatelessWidget {
  final String orderId;
  final double totalAmount;
  final String name;
  final String address;

  // Correct constructor syntax using the same class name
  const OrderConfirmationPage({
    Key? key,
    required this.orderId,
    required this.totalAmount,
    required this.name,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order Confirmation")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            SizedBox(height: 20),
            Text(
              "Order Placed Successfully!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text("Order ID:", style: TextStyle(fontSize: 16)),
            SizedBox(height: 5),
            Text(
              orderId,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text("Total Amount: ₹$totalAmount", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Shipping To:", style: TextStyle(fontSize: 16)),
            SizedBox(height: 5),
            Text(
              "$name\n$address",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
