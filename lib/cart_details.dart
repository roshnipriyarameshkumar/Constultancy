import 'package:flutter/material.dart';

class CartDetailsPage extends StatelessWidget {
  const CartDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart Details')),
      body: const Center(
        child: Text(
          'Cart Details Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
