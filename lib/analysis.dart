import 'package:flutter/material.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analysis')),
      body: const Center(
        child: Text(
          'Analysis Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
