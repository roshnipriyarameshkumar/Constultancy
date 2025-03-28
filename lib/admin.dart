import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'login.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  String? _imageBase64;
  Uint8List? _imageBytes;
  String? _editingProductId;
  bool _isAddingProduct = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        Uint8List imageBytes = await _compressImage(await image.readAsBytes());
        String base64String = _convertImageToBase64(imageBytes);
        setState(() {
          _imageBytes = imageBytes;
          _imageBase64 = base64String;
        });
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Image processing error: $e")));
      }
    }
  }

  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    try {
      var result = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: 80,
      );
      return Uint8List.fromList(result);
    } catch (e) {
      return imageBytes;
    }
  }

  String _convertImageToBase64(Uint8List imageBytes) {
    return base64Encode(imageBytes);
  }

  Uint8List _convertBase64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  void _addOrUpdateProduct() async {
    String name = _nameController.text;
    String price = _priceController.text;
    String quantity = _quantityController.text;
    String description = _descriptionController.text;
    String color = _colorController.text;

    if (name.isEmpty || price.isEmpty || quantity.isEmpty || description.isEmpty || color.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    Map<String, dynamic> productData = {
      'name': name,
      'price': price,
      'quantity': quantity,
      'description': description,
      'color': color,
      'imageBase64': _imageBase64,
    };

    if (_editingProductId == null) {
      await FirebaseFirestore.instance.collection('products').add(productData);
    } else {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(_editingProductId)
          .update(productData);
    }

    _resetForm();
  }

  void _resetForm() {
    _nameController.clear();
    _priceController.clear();
    _quantityController.clear();
    _descriptionController.clear();
    _colorController.clear();
    _imageBytes = null;
    _imageBase64 = null;
    _editingProductId = null;
    setState(() {
      _isAddingProduct = false;
    });
  }

  Widget _buildProductList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var products = snapshot.data!.docs;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];
              var productData = product.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: productData['imageBase64'] != null
                      ? Image.memory(_convertBase64ToImage(productData['imageBase64']), width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 50),
                  title: Text(productData['name'] ?? "Unknown"),
                  subtitle: Text("Price: \$${productData['price']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _editProduct(product);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _editProduct(DocumentSnapshot product) {
    var productData = product.data() as Map<String, dynamic>;
    setState(() {
      _nameController.text = productData['name'];
      _priceController.text = productData['price'];
      _quantityController.text = productData['quantity'];
      _descriptionController.text = productData['description'];
      _colorController.text = productData['color'];
      _imageBase64 = productData['imageBase64'];
      _imageBytes = _imageBase64 != null ? _convertBase64ToImage(_imageBase64!) : null;
      _editingProductId = product.id;
      _isAddingProduct = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isAddingProduct) ...[
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Product Name")),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: "Price")),
            TextField(controller: _quantityController, decoration: const InputDecoration(labelText: "Quantity")),
            TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: "Description")),
            TextField(controller: _colorController, decoration: const InputDecoration(labelText: "Color")),
            if (_imageBytes != null) Image.memory(_imageBytes!, width: 100, height: 100),
            ElevatedButton(onPressed: _pickImage, child: const Text("Upload Image")),
            ElevatedButton(onPressed: _addOrUpdateProduct, child: const Text("Save Product")),
          ],
          _buildProductList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isAddingProduct = true;
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
