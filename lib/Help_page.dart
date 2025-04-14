import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  final List<Map<String, String>> faqs = const [
    {
      "question": "How do I place an order?",
      "answer": "Browse products, add them to cart, and proceed to checkout to place your order."
    },
    {
      "question": "Can I cancel my order?",
      "answer": "Orders can be canceled within 1 hour of placing them."
    },
    {
      "question": "Do you deliver to rural areas?",
      "answer": "Yes, we deliver across India including rural pin codes."
    },
    {
      "question": "Is COD (Cash on Delivery) available?",
      "answer": "Currently, we support only prepaid orders through secure gateways."
    },
    {
      "question": "How can I track my order?",
      "answer": "Go to 'My Orders' section to see real-time delivery updates."
    },
    {
      "question": "Where can I report an issue?",
      "answer": "You can contact support or use the 'Report Issue' option from the menu."
    },
    {
      "question": "Do you accept bulk orders?",
      "answer": "Yes, contact us directly through support for wholesale or bulk queries."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 3,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  final faq = faqs[index];
                  return Card(
                    color: Colors.indigo[50],
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: const Icon(Icons.help_outline, color: Colors.indigo),
                      title: Text(
                        faq['question']!,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      children: [
                        Text(
                          faq['answer']!,
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                // You can later integrate email or support chat
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Contact Support"),
                    content: const Text("Email us at support@amsamtextile.com"),
                    actions: [
                      TextButton(
                        child: const Text("Close", style: TextStyle(color: Colors.indigo)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.email_outlined),
              label: const Text("Contact Support", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
