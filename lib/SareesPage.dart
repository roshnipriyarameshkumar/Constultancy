import 'package:flutter/material.dart';

class SareesPage extends StatelessWidget {
  const SareesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sarees")),
      body: const Center(
        child: Text(
          "This is the Sarees Page",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
