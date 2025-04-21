import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminAddOfferPage extends StatefulWidget {
  @override
  _AdminAddOfferPageState createState() => _AdminAddOfferPageState();
}

class _AdminAddOfferPageState extends State<AdminAddOfferPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _selectedProductIds = [];

  Future<void> _addOrUpdateOffer({String? offerId}) async {
    final offerTitle = _titleController.text.trim();
    final offerDescription = _descriptionController.text.trim();

    if (offerTitle.isEmpty || offerDescription.isEmpty || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields and select dates")),
      );
      return;
    }

    try {
      final data = {
        'offerTitle': offerTitle,
        'offerDescription': offerDescription,
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'applicableProductIds': _selectedProductIds,
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (offerId == null) {
        await FirebaseFirestore.instance.collection('offers').add(data);
      } else {
        await FirebaseFirestore.instance.collection('offers').doc(offerId).update(data);
      }

      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _startDate = null;
        _endDate = null;
        _selectedProductIds = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _deleteOffer(String offerId) async {
    await FirebaseFirestore.instance.collection('offers').doc(offerId).delete();
  }

  void _showEditDialog(DocumentSnapshot doc) {
    _titleController.text = doc['offerTitle'];
    _descriptionController.text = doc['offerDescription'];
    _startDate = (doc['startDate'] as Timestamp).toDate();
    _endDate = (doc['endDate'] as Timestamp).toDate();
    _selectedProductIds = List<String>.from(doc['applicableProductIds'] ?? []);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit Offer"),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 400),
            child: Column(
              children: [
                TextField(controller: _titleController, decoration: InputDecoration(labelText: "Title")),
                TextField(controller: _descriptionController, decoration: InputDecoration(labelText: "Description")),
                SizedBox(height: 10),
                _buildDatePickers(),
                _buildProductDropdown(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              _titleController.clear();
              _descriptionController.clear();
              setState(() {
                _startDate = null;
                _endDate = null;
                _selectedProductIds = [];
              });
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text("Update"),
            onPressed: () {
              _addOrUpdateOffer(offerId: doc.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickers() {
    return Column(
      children: [
        ListTile(
          title: Text("Start Date: ${_startDate != null ? DateFormat.yMd().format(_startDate!) : 'Not selected'}"),
          trailing: Icon(Icons.date_range),
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _startDate ?? DateTime.now(),
              firstDate: DateTime(2023),
              lastDate: DateTime(2030),
            );
            if (picked != null) setState(() => _startDate = picked);
          },
        ),
        ListTile(
          title: Text("End Date: ${_endDate != null ? DateFormat.yMd().format(_endDate!) : 'Not selected'}"),
          trailing: Icon(Icons.date_range),
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _endDate ?? DateTime.now().add(Duration(days: 1)),
              firstDate: DateTime(2023),
              lastDate: DateTime(2030),
            );
            if (picked != null) setState(() => _endDate = picked);
          },
        ),
      ],
    );
  }

  Widget _buildProductDropdown() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('products').get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        final products = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text("Select Products for Offer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            DropdownButtonFormField<String>(
              value: _selectedProductIds.isEmpty ? null : _selectedProductIds.first,
              decoration: InputDecoration(labelText: "Select a product"),
              onChanged: (String? newValue) {
                setState(() {
                  if (newValue != null) {
                    if (_selectedProductIds.contains(newValue)) {
                      _selectedProductIds.remove(newValue);
                    } else {
                      _selectedProductIds.add(newValue);
                    }
                  }
                });
              },
              items: products.map<DropdownMenuItem<String>>((doc) {
                final productName = doc['name'];
                final productId = doc.id;

                return DropdownMenuItem<String>(
                  value: productId,
                  child: Text(productName),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin - Manage Offers")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(controller: _titleController, decoration: InputDecoration(labelText: "Offer Title")),
                  TextField(controller: _descriptionController, decoration: InputDecoration(labelText: "Offer Description")),
                  SizedBox(height: 10),
                  _buildDatePickers(),
                  SizedBox(height: 10),
                  _buildProductDropdown(),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _addOrUpdateOffer(),
                    child: Text("Add Offer"),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('offers')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No offers added yet."));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final start = (doc['startDate'] as Timestamp).toDate();
                    final end = (doc['endDate'] as Timestamp).toDate();
                    final productIds = List<String>.from(doc['applicableProductIds'] ?? []);

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 2,
                      shadowColor: Colors.grey.shade300,
                      child: ListTile(
                        title: Text(doc['offerTitle']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc['offerDescription']),
                            Text("Valid: ${DateFormat.yMMMd().format(start)} - ${DateFormat.yMMMd().format(end)}"),
                            if (productIds.isNotEmpty)
                              Text("Products: ${productIds.join(', ')}", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditDialog(doc)),
                            IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteOffer(doc.id)),
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
    );
  }
}
