import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductForm extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? existingData;

  const ProductForm({Key? key, this.productId, this.existingData}) : super(key: key);

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  List<String> _sizes = [];
  List<String> _colors = [];
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _nameController.text = widget.existingData!['name'] ?? '';
      _descriptionController.text = widget.existingData!['description'] ?? '';
      _priceController.text = widget.existingData!['price']?.toString() ?? '';
      _sizes = List<String>.from(widget.existingData!['sizes'] ?? []);
      _colors = List<String>.from(widget.existingData!['colors'] ?? []);
    }
  }

  void _saveProduct() async {
    final productData = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'sizes': _sizes,
      'colors': _colors,
    };

    if (widget.productId == null) {
      await FirebaseFirestore.instance.collection('products').add(productData);
    } else {
      await FirebaseFirestore.instance.collection('products').doc(widget.productId).update(productData);
    }

    Navigator.pop(context);
  }

  void _addSize() {
    if (_sizeController.text.isNotEmpty) {
      setState(() {
        _sizes.add(_sizeController.text.trim());
        _sizeController.clear();
      });
    }
  }

  void _addColor() {
    if (_colorController.text.isNotEmpty) {
      setState(() {
        _colors.add(_colorController.text.trim());
        _colorController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.productId == null ? "Add Product" : "Edit Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Product Name")),
              TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: "Description")),
              TextField(controller: _priceController, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),

              const SizedBox(height: 10),

              // Sizes Input
              Wrap(
                children: _sizes.map((size) => Chip(
                  label: Text(size),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () => setState(() => _sizes.remove(size)),
                )).toList(),
              ),
              Row(
                children: [
                  Expanded(child: TextField(controller: _sizeController, decoration: const InputDecoration(labelText: "Add Size"))),
                  IconButton(icon: const Icon(Icons.add), onPressed: _addSize),
                ],
              ),

              const SizedBox(height: 10),

              // Colors Input
              Wrap(
                children: _colors.map((color) => Chip(
                  label: Text(color),
                  deleteIcon: const Icon(Icons.close),
                  onDeleted: () => setState(() => _colors.remove(color)),
                )).toList(),
              ),
              Row(
                children: [
                  Expanded(child: TextField(controller: _colorController, decoration: const InputDecoration(labelText: "Add Color"))),
                  IconButton(icon: const Icon(Icons.add), onPressed: _addColor),
                ],
              ),

              const SizedBox(height: 20),

              ElevatedButton(onPressed: _saveProduct, child: const Text("Save Product")),
            ],
          ),
        ),
      ),
    );
  }
}
