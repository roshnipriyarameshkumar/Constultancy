import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: const Center(
        child: Text(
          'Order Details Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
