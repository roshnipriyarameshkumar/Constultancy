import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin.dart';
import 'homepage.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Widget handleAuthState() {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(snapshot.data!.uid).get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final userData = userSnapshot.data!;
              final role = userData['role'] ?? 'user';
              return role == 'admin' ? AdminPage() : const HomePage();

            },
          );
        }
        return const LoginScreen();
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  Future<void> _signInAnonymously() async {
    await FirebaseAuth.instance.signInAnonymously();
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({
      'role': 'user',
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: ElevatedButton(
          onPressed: _signInAnonymously,
          child: const Text("Login Anonymously"),
        ),
      ),
    );
  }
}
