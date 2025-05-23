import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sample_app/Help_page.dart';
import 'package:sample_app/terms_conditions.dart';

import 'order_history_page.dart';
import 'orderinfo.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data() as Map<String, dynamic>?;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            // Profile Header Section
            CircleAvatar(
              radius: 50,
              backgroundImage: userData != null && userData!['profileImage'] != null
                  ? NetworkImage(userData!['profileImage'])
                  : const AssetImage('assets/profile_image.jpg') as ImageProvider,
            ),
            const SizedBox(height: 10),
            Text(
              userData?['fullName'] ?? 'Loading...',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              userData?['email'] ?? user?.email ?? 'Loading...',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // List of Options
            // List of Options
            Expanded(
              child: ListView(
                children: [
                  _buildListTile(Icons.shopping_bag, 'Order Status', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderInfoPage(),
                      ),
                    );
                  }),

                  _buildListTile(Icons.history, 'Order History', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderHistoryPage(), // Add const if the page is stateless
                      ),
                    );
                  }),



                  _buildListTile(Icons.description, 'Terms and Conditions', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TermsAndConditions()),
                    );
                  }),

                  _buildListTile(Icons.help_outline, 'Help', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HelpPage()),
                    );
                  }),

                  _buildListTile(Icons.exit_to_app, 'Sign Out', () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  }),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(title),
      onTap: onTap,
    );
  }
}
