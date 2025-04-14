import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SupplierAdminPage extends StatefulWidget {
  const SupplierAdminPage({super.key});

  @override
  State<SupplierAdminPage> createState() => _SupplierAdminPageState();
}

class _SupplierAdminPageState extends State<SupplierAdminPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _supplierNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final CollectionReference _supplierCollection =
  FirebaseFirestore.instance.collection('suppliers');

  String? editingDocId;
  bool showForm = false;

  void _clearFields() {
    _supplierNameController.clear();
    _contactController.clear();
    _productNameController.clear();
    _quantityController.clear();
    _priceController.clear();
    editingDocId = null;
    setState(() => showForm = false);
  }

  Future<void> _addOrUpdateSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'supplierName': _supplierNameController.text.trim(),
      'contactNumber': _contactController.text.trim(),
      'productName': _productNameController.text.trim(),
      'quantity': int.tryParse(_quantityController.text) ?? 0,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'timestamp': FieldValue.serverTimestamp(),
    };

    if (editingDocId != null) {
      await _supplierCollection.doc(editingDocId).update(data);
    } else {
      await _supplierCollection.add(data);
    }

    _clearFields();
  }

  Future<void> _deleteSupplier(String docId) async {
    await _supplierCollection.doc(docId).delete();
  }

  void _populateFields(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    setState(() {
      editingDocId = doc.id;
      _supplierNameController.text = data['supplierName'] ?? '';
      _contactController.text = data['contactNumber'] ?? '';
      _productNameController.text = data['productName'] ?? '';
      _quantityController.text = data['quantity'].toString();
      _priceController.text = data['price'].toString();
      showForm = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supplier Management"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (showForm)
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_supplierNameController, "Supplier Name"),
                    _buildTextField(_contactController, "Contact Number", keyboardType: TextInputType.phone),
                    _buildTextField(_productNameController, "Product Name"),
                    _buildTextField(_quantityController, "Quantity", keyboardType: TextInputType.number),
                    _buildTextField(_priceController, "Price", keyboardType: TextInputType.number),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _addOrUpdateSupplier,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              editingDocId == null ? 'Add Supplier' : 'Update Supplier',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: _clearFields,
                          icon: const Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            const Divider(),
            const Text("Supplier Entries", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _supplierCollection.orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.local_shipping, color: Colors.indigo),
                          title: Text(data['supplierName'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Contact: ${data['contactNumber']}"),
                              Text("Product: ${data['productName']}"),
                              Text("Quantity: ${data['quantity']}"),
                              Text("Price: ₹${data['price']}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _populateFields(doc),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteSupplier(doc.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: !showForm
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            showForm = true;
            editingDocId = null;
          });
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
        tooltip: 'Add Supplier',
      )
          : null,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) => value == null || value.isEmpty ? 'Enter $label' : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.indigo[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
