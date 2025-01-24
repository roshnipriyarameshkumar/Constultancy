import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Profile Header Section
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_image.jpg'), // Replace with your image
            ),
            const SizedBox(height: 10),
            const Text(
              'John Doe', // Replace with dynamic username
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              'johndoe@example.com', // Replace with dynamic email
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // List of Options (Customer Care, Terms, etc.)
            Expanded(
              child: ListView(
                children: [
                  // Customer Care
                  ListTile(
                    leading: const Icon(Icons.headset_mic, color: Colors.teal),
                    title: const Text('Customer Care'),
                    onTap: () {
                      // Implement customer care logic
                    },
                  ),

                  // Invite Friends
                  ListTile(
                    leading: const Icon(Icons.group_add, color: Colors.teal),
                    title: const Text('Invite Friends'),
                    onTap: () {
                      // Implement invite friends logic
                    },
                  ),

                  // Terms and Conditions
                  ListTile(
                    leading: const Icon(Icons.description, color: Colors.teal),
                    title: const Text('Terms and Conditions'),
                    onTap: () {
                      // Implement Terms and Conditions logic
                    },
                  ),

                  // Help
                  ListTile(
                    leading: const Icon(Icons.help, color: Colors.teal),
                    title: const Text('Help'),
                    onTap: () {
                      // Implement Help logic
                    },
                  ),

                  // How to Return Product
                  ListTile(
                    leading: const Icon(Icons.undo, color: Colors.teal),
                    title: const Text('How to Return Product'),
                    onTap: () {
                      // Implement Return Product logic
                    },
                  ),

                  // How to Redeem Coupon
                  ListTile(
                    leading: const Icon(Icons.card_giftcard, color: Colors.teal),
                    title: const Text('How to Redeem Coupon'),
                    onTap: () {
                      // Implement Redeem Coupon logic
                    },
                  ),

                  // Sign Out Option
                  ListTile(
                    leading: const Icon(Icons.exit_to_app, color: Colors.teal),
                    title: const Text('Sign Out'),
                    onTap: () {
                      // Implement Sign Out logic
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
