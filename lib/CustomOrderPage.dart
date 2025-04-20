import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class CustomOrderPage extends StatefulWidget {
  const CustomOrderPage({super.key});

  @override
  State<CustomOrderPage> createState() => _CustomOrderPageState();
}

class _CustomOrderPageState extends State<CustomOrderPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  File? _imageFile;
  String? _imageBase64;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      // Compress image
      final compressed = await FlutterImageCompress.compressWithFile(
        picked.path,
        quality: 50,
      );

      if (compressed != null) {
        setState(() {
          _imageFile = File(picked.path);
          _imageBase64 = base64Encode(compressed);
        });
      }
    }
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a product image")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      final cartData = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'size': _sizeController.text.trim(),
        'color': _colorController.text.trim(),
        'imageBase64': _imageBase64,
        'quantity': 1,
        'type': 'custom', // Mark as custom product
        'timestamp': Timestamp.now(),
        'userId': userId,
      };

      // Add the custom order details directly to the 'cart' collection
      await FirebaseFirestore.instance
          .collection('cart')
          .add(cartData);

      setState(() => _isSubmitting = false);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Order Submitted"),
          content: const Text("Custom order has been placed and added to your cart!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("OK"),
            )
          ],
        ),
      );

      _formKey.currentState?.reset();
      setState(() {
        _imageFile = null;
        _imageBase64 = null;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to place order: $e")),
      );
    }
  }

  Widget _buildTextField(
      {required TextEditingController controller,
        required String label,
        int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (val) => val == null || val.isEmpty ? "Required" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Order'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "This is a custom order page. Fill in the details below.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              _buildTextField(controller: _nameController, label: "Product Name"),
              const SizedBox(height: 16),
              _buildTextField(
                  controller: _descController,
                  label: "Description",
                  maxLines: 3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(controller: _sizeController, label: "Size")),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField(controller: _colorController, label: "Color")),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                onPressed: _pickImage,
                label: const Text("Upload Image"),
              ),
              if (_imageFile != null) ...[
                const SizedBox(height: 10),
                Image.file(_imageFile!, height: 150, fit: BoxFit.cover),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white, // <-- this ensures white text
                  ),
                  onPressed: _isSubmitting ? null : _submitOrder,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit Custom Order"),
                ),

              ),
            ],
          ),
        ),
      ),
    );
  }
}