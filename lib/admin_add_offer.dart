import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminAddOfferPage extends StatefulWidget {
  @override
  _AdminAddOfferPageState createState() => _AdminAddOfferPageState();
}

class _AdminAddOfferPageState extends State<AdminAddOfferPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  void _addOrUpdateOffer({String? offerId}) async {
    final offerTitle = _titleController.text.trim();
    final offerDescription = _descriptionController.text.trim();

    if (offerTitle.isEmpty || offerDescription.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      if (offerId == null) {
        // Add new offer
        await FirebaseFirestore.instance.collection('offers').add({
          'offerTitle': offerTitle,
          'offerDescription': offerDescription,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        // Update existing offer
        await FirebaseFirestore.instance.collection('offers').doc(offerId).update({
          'offerTitle': offerTitle,
          'offerDescription': offerDescription,
        });
      }

      _titleController.clear();
      _descriptionController.clear();
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

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit Offer"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: "Title")),
            TextField(controller: _descriptionController, decoration: InputDecoration(labelText: "Description")),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              _titleController.clear();
              _descriptionController.clear();
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
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: "Offer Title"),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: "Offer Description"),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _addOrUpdateOffer(),
                  child: Text("Add Offer"),
                ),
              ],
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
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(doc['offerTitle']),
                        subtitle: Text(doc['offerDescription']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showEditDialog(doc),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteOffer(doc.id),
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
    );
  }
}
