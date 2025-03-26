import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
class AdminPage extends StatelessWidget {
  const AdminPage({Key? key}) : super(key: key);

  // Builds a premium product card
  Widget _buildProductCard(DocumentSnapshot product) {
    final data = product.data() as Map<String, dynamic>;
    final String name = data['name'] ?? 'Product Name';
    final String description = data['description'] ?? '';
    final double price =
    data['price'] != null ? (data['price'] as num).toDouble() : 0.0;
    final List<dynamic> imageList = data['images'] ?? [];

    // Decode base64 string to image (Use first image if multiple exist)
    Uint8List? imageBytes;
    if (imageList.isNotEmpty && imageList.first is String) {
      imageBytes = base64Decode(imageList.first);
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display base64 image or placeholder
          Expanded(
            child: imageBytes != null
                ? Image.memory(
              imageBytes,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Container(
              width: double.infinity,
              color: Colors.grey.shade300,
              child: Icon(Icons.image, size: 60, color: Colors.grey.shade600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '\$$price',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Premium gradient AppBar
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      // Floating button on right to navigate to ProductForm
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductForm()),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // Stream products from Firestore and display them
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data!.docs;
          if (products.isEmpty) {
            // Attractive empty state
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_mall_directory,
                      size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 20),
                  const Text(
                    'No Products Found!',
                    style:
                    TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Start adding products using the button below.',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                return _buildProductCard(products[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class ProductVariant {
  String size;
  String color;
  double price;

  ProductVariant({required this.size, required this.color, required this.price});

  Map<String, dynamic> toMap() {
    return {'size': size, 'color': color, 'price': price};
  }
}

class ProductForm extends StatefulWidget {
  const ProductForm({Key? key}) : super(key: key);

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Form fields
  String productName = '';
  String productDescription = '';

  // List to hold base64 strings of images
  final List<String> _imageBase64List = [];

  // List of product variants
  final List<ProductVariant> _variants = [];

  // Controllers for variant fields
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Function to pick multiple images
  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage(
      imageQuality: 80, // Adjust quality to reduce file size if needed
    );
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      // Limit to 5 images max.
      final files = pickedFiles.take(5);
      for (var file in files) {
        final bytes = await file.readAsBytes();
        final base64Str = base64Encode(bytes);
        setState(() {
          _imageBase64List.add(base64Str);
        });
      }
    }
  }

  // Function to add a variant
  void _addVariant() {
    if (_priceController.text.isNotEmpty &&
        _sizeController.text.isNotEmpty &&
        _colorController.text.isNotEmpty) {
      final variant = ProductVariant(
        size: _sizeController.text,
        color: _colorController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
      );
      setState(() {
        _variants.add(variant);
      });
      _sizeController.clear();
      _colorController.clear();
      _priceController.clear();
    }
  }

  // Save product function (simulate sending to Firebase)
  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Construct final product data
      final productData = {
        'name': productName,
        'description': productDescription,
        'images': _imageBase64List,
        'variants': _variants.map((v) => v.toMap()).toList(),
        'createdAt': FieldValue.serverTimestamp(), // optional timestamp field
      };

      try {
        // Save the product data to Firestore "products" collection
        await FirebaseFirestore.instance
            .collection('products')
            .add(productData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product saved successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: $e')),
        );
      }
    }
  }


  @override
  void dispose() {
    _sizeController.dispose();
    _colorController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Custom InputDecoration for a polished look.
    InputDecoration _inputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );
    }

    return Scaffold(
      // A secondary AppBar within the form page (optional)
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Add Product', style: TextStyle(color: Colors.black87)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product Name Field
                  TextFormField(
                    decoration: _inputDecoration('Product Name'),
                    validator: (value) => value == null || value.isEmpty ? 'Enter product name' : null,
                    onSaved: (value) => productName = value ?? '',
                  ),
                  const SizedBox(height: 20),
                  // Product Description Field
                  TextFormField(
                    decoration: _inputDecoration('Description'),
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty ? 'Enter product description' : null,
                    onSaved: (value) => productDescription = value ?? '',
                  ),
                  const SizedBox(height: 20),
                  // Image Picker Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Product Images',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.photo_library,color: Colors.white,),
                        label: const Text('Add Images',style: TextStyle(color:Colors.white),),
                        onPressed: _pickImages,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Display Selected Images
                  _imageBase64List.isEmpty
                      ? const Text('No images selected.', textAlign: TextAlign.center)
                      : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _imageBase64List.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(_imageBase64List[index]),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _imageBase64List.removeAt(index);
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.close, size: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Variants Section Title
                  const Text(
                    'Product Variants',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Product Variant Entry Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _sizeController,
                          decoration: _inputDecoration('Size'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _colorController,
                          decoration: _inputDecoration('Color'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: _inputDecoration('Price'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _addVariant,
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Display Added Variants
                  _variants.isEmpty
                      ? const Text('No variants added.', textAlign: TextAlign.center)
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _variants.length,
                    itemBuilder: (context, index) {
                      final variant = _variants[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text('Size: ${variant.size}, Color: ${variant.color}',
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Price: \$${variant.price.toStringAsFixed(2)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                _variants.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  // Save Button
                  ElevatedButton(
                    onPressed: _saveProduct,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Save Product',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
