import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:sample_app/reports_page.dart';
import 'package:sample_app/restore_alert_page.dart';
import 'package:sample_app/supplier_admin_page.dart';
import 'package:sample_app/user_logs_page.dart';
import 'admin_add_offer.dart';
import 'admin_orders.dart';
import 'inventory_management_page.dart';
import 'login.dart';
import 'reports_page.dart';
import 'sales_report.dart';

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
          content: SingleChildScrollView( // Wrap the content in SingleChildScrollView
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Product Name")),
                const SizedBox(height: 8), // Add some spacing
                TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Price")),
                const SizedBox(height: 8),
                TextField(controller: _quantityController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Quantity")),
                const SizedBox(height: 8),
                TextField(controller: _descriptionController, maxLines: 2, decoration: const InputDecoration(labelText: "Description")),
                const SizedBox(height: 8),
                TextField(controller: _colorController, decoration: const InputDecoration(labelText: "Color")),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _pickImage, child: const Text("Pick Image")),
                if (_imageBytes != null) // Show preview if image is picked
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.memory(_imageBytes!, height: 80),
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
                if (_nameController.text.isEmpty || _priceController.text.isEmpty ||
                    _quantityController.text.isEmpty || _descriptionController.text.isEmpty ||
                    _colorController.text.isEmpty) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text("Please fill all fields")));
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
                  await FirebaseFirestore.instance.collection('products').add(productData);
                } else {
                  await FirebaseFirestore.instance.collection('products').doc(_editingProductId).update(productData);
                }
                Navigator.of(context).pop();
                _resetForm();
              },
              child: Text(_editingProductId == null ? "Add" : "Update"),
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

  Widget _buildProductList() {
    return StreamBuilder<QuerySnapshot>(
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
            return ListTile(
              leading: productData['imageBase64'] != null
                  ? Image.memory(_convertBase64ToImage(productData['imageBase64']), width: 50, height: 50)
                  : null,
              title: Text(productData['name']),
              subtitle: Text("Price: \₹${productData['price']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: Icon(Icons.edit), onPressed: () => _addOrUpdateProduct(productId: product.id)),
                  IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteProduct(product.id)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Navigate to the RestoreAlertPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RestoreAlertPage()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.indigo[700],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('👤 Admin', style: TextStyle(color: Colors.white, fontSize: 22)),
                  SizedBox(height: 8),
                  Text('Manage your store', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            ListTile(
              leading: Icon(Icons.dashboard, color: Colors.white),
              title: Text('Order Status', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminOrdersPage()),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.people_alt, color: Colors.white),
              title: Text('User Logs', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserLogsPage()),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.local_offer, color: Colors.white),
              title: Text('Offers', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminAddOfferPage()),
                );
              },

            ),
            ListTile(
              leading: Icon(Icons.inventory_2, color: Colors.white),
              title: Text('Inventory', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InventoryManagementPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.local_shipping, color: Colors.white),
              title: Text('Supplier Management', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SupplierAdminPage()),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.bar_chart, color: Colors.white),
              title: Text('Sales Insights', style: TextStyle(color: Colors.white)),
              onTap: () {
                // TODO: Navigate to Sales Insights Page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SalesReportPage(),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.insert_drive_file, color: Colors.white),
              title: Text('Reports', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportsPage()),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text('Sign Out', style: TextStyle(color: Colors.white)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [Expanded(child: _buildProductList())],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateProduct(),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }


}
