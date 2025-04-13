import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InventoryManagementPage extends StatelessWidget {
  const InventoryManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
          'Inventory Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading data.'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final products = snapshot.data!.docs;

            if (products.isEmpty) {
              return const Center(child: Text('No products found.'));
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.shade100),
                ),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(Colors.indigo),
                  headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  dataRowHeight: 56,
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('S.No')),
                    DataColumn(label: Text('Product Name')),
                    DataColumn(label: Text('Quantity')),
                  ],
                  rows: List<DataRow>.generate(
                    products.length,
                        (index) {
                      final product = products[index];
                      final name = product['name'] ?? 'Unnamed';
                      final quantity = product['quantity'];
                      final qty = quantity is int ? quantity : int.tryParse('$quantity') ?? 0;

                      return DataRow(
                        cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          )),
                          DataCell(
                            Text(
                              '$qty',
                              style: TextStyle(
                                color: qty <= 5 ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
