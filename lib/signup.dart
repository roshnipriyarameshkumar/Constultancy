import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _signup() async {
    setState(() => _isLoading = true);

    String fullName = _fullNameController.text.trim();
    String phoneNumber = _phoneNumberController.text.trim();
    String address = _addressController.text.trim();
    String email = _signupEmailController.text.trim();
    String password = _signupPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (fullName.isEmpty || phoneNumber.isEmpty || address.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("All fields are required!");
      setState(() => _isLoading = false);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match!");
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Check if email exists
      var methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        _showSnackBar("Email already exists! Please use a different email.");
        setState(() => _isLoading = false);
        return;
      }

      // Create user
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'address': address,
          'email': email,
          'createdAt': Timestamp.now(),
        });

        await user.sendEmailVerification();

        _showSnackBar("Account Created Successfully! Please verify your email.");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amsam Tex'),
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
                'Create Your Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign up to get started with Amsam Tex',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              _buildTextField(_fullNameController, 'Full Name', Icons.person),
              const SizedBox(height: 20),
              _buildTextField(_phoneNumberController, 'Phone Number', Icons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 20),
              _buildTextField(_addressController, 'Address', Icons.home),
              const SizedBox(height: 20),
              _buildTextField(_signupEmailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildTextField(_signupPasswordController, 'Password', Icons.lock, isObscure: true),
              const SizedBox(height: 20),
              _buildTextField(_confirmPasswordController, 'Confirm Password', Icons.lock, isObscure: true),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  backgroundColor: Colors.teal,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Sign Up',
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(fontSize: 16, color: Colors.teal),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text, bool isObscure = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        prefixIcon: Icon(icon),
      ),
      keyboardType: keyboardType,
      obscureText: isObscure,
    );
  }
}
