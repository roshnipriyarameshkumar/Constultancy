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

      if (userId == null) {
        throw Exception("User not logged in");
      }

      final data = {
        'productName': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'size': _sizeController.text.trim(),
        'color': _colorController.text.trim(),
        'imageBase64': _imageBase64,
        'timestamp': Timestamp.now(),
        'userId': userId,
      };

      // 1. Add to customorder collection
      final customOrderRef = await FirebaseFirestore.instance
          .collection('customorder')
          .add(data);

      // 2. Add to user's cart
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(customOrderRef.id)
          .set({
        'productId': customOrderRef.id,
        'productName': data['productName'],
        'description': data['description'],
        'size': data['size'],
        'color': data['color'],
        'imageBase64': data['imageBase64'],
        'quantity': 1,
        'isCustom': true,
        'timestamp': Timestamp.now(),
      });

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Custom order placed and added to cart!")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Order'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "This is a custom order page. Customers can place orders based on their own design requirements.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Product Name",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _sizeController,
                decoration: const InputDecoration(
                  labelText: "Size",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: "Color",
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                onPressed: _pickImage,
                label: const Text("Pick Product Image"),
              ),
              const SizedBox(height: 10),
              if (_imageFile != null)
                Image.file(_imageFile!, height: 150, fit: BoxFit.cover),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: _isSubmitting ? null : _submitOrder,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Submit Custom Order"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
