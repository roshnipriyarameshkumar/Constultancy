import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart'; // Import your Home Page

class EmailVerificationPage extends StatefulWidget {
  final User user;

  const EmailVerificationPage(this.user, {super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool isVerified = false;
  bool isChecking = false;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
  }

  // Send verification email
  Future<void> _sendVerificationEmail() async {
    try {
      await widget.user.sendEmailVerification();
      _showSnackBar("Verification email sent! Please check your inbox.");
    } catch (e) {
      _showSnackBar("Error sending email: ${e.toString()}");
    }
  }

  // Check email verification status
  Future<void> _checkEmailVerification() async {
    setState(() {
      isChecking = true;
    });

    await widget.user.reload(); // Refresh user data
    if (widget.user.emailVerified) {
      setState(() {
        isVerified = true;
      });

      _showSnackBar("Email verified! Redirecting...");

      // Navigate to Home Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      _showSnackBar("Email not verified. Please check your inbox.");
    }

    setState(() {
      isChecking = false;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Your Email")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "A verification email has been sent. Please check your inbox and verify your email.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isChecking ? null : _checkEmailVerification,
              child: isChecking
                  ? const CircularProgressIndicator()
                  : const Text("I've Verified My Email"),
            ),
          ],
        ),
      ),
    );
  }
}
