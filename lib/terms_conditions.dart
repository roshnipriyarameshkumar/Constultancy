import 'package:flutter/material.dart';

class TermsAndConditions extends StatelessWidget {
  const TermsAndConditions({super.key});

  final List<Map<String, String>> termsList = const [
    {
      "title": "Order Confirmation",
      "desc": "Orders are confirmed only after successful payment through the available options."
    },
    {
      "title": "Delivery Time",
      "desc": "Delivery may take 5-7 business days depending on your location and availability."
    },
    {
      "title": "Product Authenticity",
      "desc": "All products are original and manufactured with premium quality materials."
    },
    {
      "title": "Usage of Fabrics",
      "desc": "Fabrics are sold strictly for personal or authorized commercial use."
    },
    {
      "title": "Image Representation",
      "desc": "Colors and texture may slightly vary due to lighting and screen display differences."
    },
    {
      "title": "Cancellation Policy",
      "desc": "Orders once placed cannot be canceled after 1 hour of confirmation."
    },
    {
      "title": "No Return Policy",
      "desc": "Due to the nature of textiles, returns or exchanges are not accepted unless damaged."
    },
    {
      "title": "Payment Security",
      "desc": "All transactions are secured using encrypted gateways for your protection."
    },
    {
      "title": "Privacy Protection",
      "desc": "We respect your privacy and never share your data with third-party services."
    },
    {
      "title": "Legal Compliance",
      "desc": "Users must comply with applicable textile usage and copyright laws."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Terms & Conditions", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 3,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: termsList.length,
        itemBuilder: (context, index) {
          final item = termsList[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            color: Colors.indigo[50],
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.indigo),
              title: Text(
                item["title"]!,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 16),
              ),
              subtitle: Text(
                item["desc"]!,
                style: const TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ),
          );
        },
      ),
    );
  }
}
