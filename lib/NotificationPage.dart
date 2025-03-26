import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {
        'title': '🎉 Special Offer!',
        'message': 'Get 20% off on all textiles this weekend only!',
        'time': '2 hours ago'
      },
      {
        'title': '🚚 Order Shipped',
        'message': 'Your order #12345 has been shipped and is on the way!',
        'time': '5 hours ago'
      },
      {
        'title': '🎁 Exclusive Deal!',
        'message': 'Buy 2 sarees and get 1 free! Limited time offer.',
        'time': 'Yesterday'
      },
      {
        'title': '📦 Order Delivered',
        'message': 'Your order #67890 has been delivered successfully!',
        'time': '2 days ago'
      },
      {
        'title': '🔥 Flash Sale!',
        'message': 'Flat 50% off on all winter collections until midnight!',
        'time': '3 days ago'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.indigo,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            child: ListTile(
              leading: Icon(
                Icons.notifications_active,
                color: Colors.indigo,
                size: 30,
              ),
              title: Text(
                notifications[index]['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notifications[index]['message']!),
                  const SizedBox(height: 5),
                  Text(
                    notifications[index]['time']!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[600],
                size: 18,
              ),
              onTap: () {
                // Handle tap for notification details if needed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening: ${notifications[index]['title']}'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
