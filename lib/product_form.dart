import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ProductFormPage extends StatefulWidget {
  final DocumentSnapshot? product;

  const ProductFormPage({super.key, this.product});

  @override
  _ProductFormPageState createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  List<String> _colors = [];
  List<String> _sizes = [];
  String? _imageBase64;
  Uint8List? _imageBytes;
  String? _editingProductId;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      var productData = widget.product!.data() as Map<String, dynamic>;
      _nameController.text = productData['name'];
      _priceController.text = productData['price'];
      _quantityController.text = productData['quantity'];
      _descriptionController.text = productData['description'];
      _colors = List<String>.from(productData['colors'] ?? []);
      _sizes = List<String>.from(productData['sizes'] ?? []);
      _imageBase64 = productData['imageBase64'];
      _imageBytes = _imageBase64 != null ? base64Decode(_imageBase64!) : null;
      _editingProductId = widget.product!.id;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Uint8List imageBytes = await _compressImage(await image.readAsBytes());
      String base64String = base64Encode(imageBytes);
      setState(() {
        _imageBytes = imageBytes;
        _imageBase64 = base64String;
      });
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

  void _addOrUpdateProduct() async {
    String name = _nameController.text;
    String price = _priceController.text;
    String quantity = _quantityController.text;
    String description = _descriptionController.text;

    if (name.isEmpty || price.isEmpty || quantity.isEmpty || description.isEmpty || _colors.isEmpty || _sizes.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    Map<String, dynamic> productData = {
      'name': name,
      'price': price,
      'quantity': quantity,
      'description': description,
      'colors': _colors,
      'sizes': _sizes,
      'imageBase64': _imageBase64,
    };

    if (_editingProductId == null) {
      await FirebaseFirestore.instance.collection('products').add(productData);
    } else {
      await FirebaseFirestore.instance.collection('products').doc(_editingProductId).update(productData);
    }

    Navigator.pop(context);
  }

  void _addColor() {
    if (_colorController.text.isNotEmpty) {
      setState(() {
        _colors.add(_colorController.text);
        _colorController.clear();
      });
    }
  }

  void _addSize() {
    if (_sizeController.text.isNotEmpty) {
      setState(() {
        _sizes.add(_sizeController.text);
        _sizeController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add/Edit Product")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Product Name")),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: "Price")),
            TextField(controller: _quantityController, decoration: const InputDecoration(labelText: "Quantity")),
            TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: "Description")),

            Row(
              children: [
                Expanded(child: TextField(controller: _colorController, decoration: const InputDecoration(labelText: "Add Color"))),
                IconButton(icon: const Icon(Icons.add), onPressed: _addColor),
              ],
            ),
            Wrap(children: _colors.map((color) => Chip(label: Text(color))).toList()),

            Row(
              children: [
                Expanded(child: TextField(controller: _sizeController, decoration: const InputDecoration(labelText: "Add Size"))),
                IconButton(icon: const Icon(Icons.add), onPressed: _addSize),
              ],
            ),
            Wrap(children: _sizes.map((size) => Chip(label: Text(size))).toList()),

            if (_imageBytes != null) Image.memory(_imageBytes!, width: 100, height: 100),
            ElevatedButton(onPressed: _pickImage, child: const Text("Upload Image")),
            ElevatedButton(onPressed: _addOrUpdateProduct, child: const Text("Save Product")),
          ],
        ),
      ),
    );
  }
}
