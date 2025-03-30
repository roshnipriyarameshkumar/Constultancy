import 'package:flutter/material.dart';

class OrderConfirmationPage extends StatelessWidget {
  final double totalAmount;
  final String name;
  final String address;


  OrderConfirmationPage({
    required this.totalAmount,
    required this.name,
    required this.address,

  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order Confirmation")),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 100),
              SizedBox(height: 20),
              Text("Payment is Done!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 10),
              Text("Thank you, $name", style: TextStyle(fontSize: 18)),
              SizedBox(height: 5),
              Text("Shipping to: $address", style: TextStyle(fontSize: 18)),
              SizedBox(height: 10),

              Text("Total Amount: ₹${totalAmount.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: Size(200, 50)),
                child: Text("Back to Home", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
