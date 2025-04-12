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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image processing error: $e")),
        );
      }
    }
  }

  Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
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

  void _addOrUpdateProduct({String? productId}) {
    _resetForm();
    setState(() {
      _editingProductId = productId;
      _isAddingProduct = true;
    });
    _showAddProductDialog();
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_editingProductId == null ? "Add Product" : "Edit Product"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Product Name"),
                ),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: "Price"),
                ),
                TextField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: "Quantity"),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                TextField(
                  controller: _colorController,
                  decoration: const InputDecoration(labelText: "Color"),
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text("Pick Image"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetForm();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isEmpty ||
                    _priceController.text.isEmpty ||
                    _quantityController.text.isEmpty ||
                    _descriptionController.text.isEmpty ||
                    _colorController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Please fill all fields")));
                  return;
                }

                Map<String, dynamic> productData = {
                  'name': _nameController.text,
                  'price': _priceController.text,
                  'quantity': _quantityController.text,
                  'description': _descriptionController.text,
                  'color': _colorController.text,
                  'imageBase64': _imageBase64,
                };

                if (_editingProductId == null) {
                  await FirebaseFirestore.instance
                      .collection('products')
                      .add(productData);
                } else {
                  await FirebaseFirestore.instance
                      .collection('products')
                      .doc(_editingProductId)
                      .update(productData);
                }
                Navigator.of(context).pop();
                _resetForm();
              },
              child: Text(_editingProductId == null ? "Add" : "Update"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(String productId) async {
    await FirebaseFirestore.instance.collection('products').doc(productId).delete();
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
    _isAddingProduct = false;
  }

  // Builds a list view of products.
  Widget _buildProductList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var products = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          itemCount: products.length,
          itemBuilder: (context, index) {
            var product = products[index];
            var productData = product.data() as Map<String, dynamic>;
            return ListTile(
              leading: productData['imageBase64'] != null
                  ? Image.memory(
                _convertBase64ToImage(productData['imageBase64']),
                width: 50,
                height: 50,
              )
                  : null,
              title: Text(productData['name']),
              subtitle: Text("Price: \$${productData['price']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _addOrUpdateProduct(productId: product.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteProduct(product.id),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Builds a list view for custom order notifications with a back button.
  Widget _buildCustomOrderNotifications() {
    return SafeArea(
      child: Column(
        children: [
          // Back button row.
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // Navigate back to the previous screen.
                  Navigator.pop(context);
                },
              ),
              const Text(
                "Custom Orders",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          // Expanded list of notifications.
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('adminNotifications')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var notifications = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    var notif = notifications[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.notification_important),
                      title: Text(notif['message'] ?? ''),
                      subtitle: Text(notif['order'] != null
                          ? "Order details: ${notif['order']}"
                          : ''),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Products and Custom Orders Notifications.
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          backgroundColor: Colors.indigo,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Products"),
              Tab(text: "Custom Orders"),
            ],
          ),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              ListTile(title: const Text('Home'), onTap: () {}),
              ListTile(title: const Text('Profile'), onTap: () {}),
              ListTile(title: const Text('Sales Insights'), onTap: () {}),
              ListTile(title: const Text('More'), onTap: () {}),
              ListTile(title: const Text('Sign Out'), onTap: () {}),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Product management.
            SafeArea(child: _buildProductList()),
            // Tab 2: Custom orders notifications.
            SafeArea(child: _buildCustomOrderNotifications()),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addOrUpdateProduct(),
          child: const Icon(Icons.add),
          backgroundColor: Colors.indigo,
        ),
      ),
    );
  }
}
