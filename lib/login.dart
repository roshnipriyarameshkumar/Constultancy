import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin.dart';
import 'home.dart';
import 'signup.dart';
import 'otpverification.dart';
import 'ForgetPassword.dart';
import 'EmailVerificationPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  void _login() async {
    String email = _loginEmailController.text.trim().toLowerCase();
    String password = _loginPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill in both fields");
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user == null || user.uid.isEmpty) {
        _showSnackBar("Authentication failed. Please try again.");
        return;
      }

      // Check if the user is an admin
      if (email == "admin@gmail.com" && password == "admin1") {
        _showSnackBar("Admin Login Successful!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPage()),
        );
        return;
      }

      var userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        _showSnackBar("No user data found. Please sign up again.");
        return;
      }

      var userData = userQuery.docs.first.data();

      if (!user.emailVerified) {
        await user.sendEmailVerification();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EmailVerificationPage(user)),
        );
        return;
      }

      if (userData.containsKey('status') && userData['status'] == 'inactive') {
        _showSnackBar("Your account is inactive. Please contact support.");
        return;
      }

      _showSnackBar("Login Successful!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      if (e is FirebaseAuthException) {
        _showSnackBar(_getAuthErrorMessage(e.code));
      } else {
        _showSnackBar("An unexpected error occurred. Please try again.");
      }
    }
  }


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return "No user found with this email.";
      case 'wrong-password':
        return "Incorrect password. Try again.";
      case 'network-request-failed':
        return "Network error. Check your internet connection.";
      case 'too-many-requests':
        return "Too many failed attempts. Try again later.";
      default:
        return "Login failed. Please try again.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to Amsam Tex'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Log in to continue to Amsam Tex',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _loginEmailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _loginPasswordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(fontSize: 16, color: Colors.teal),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  backgroundColor: Colors.teal,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                  );
                },
                child: const Text(
                  'Don’t have an account? Sign Up',
                  style: TextStyle(fontSize: 16, color: Colors.teal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
