import 'package:flutter/material.dart';
import 'payment_page.dart';

class AddressPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;

  const AddressPage({
    Key? key,
    required this.cartItems,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  void proceedToPayment() {
    if (_formKey.currentState!.validate()) {
      final address = {
        'name': nameController.text,
        'city': cityController.text,
        'pincode': pincodeController.text,
        'address': addressController.text,
      };
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>PaymentPage(
            cartItems: widget.cartItems,
            address: address,
            totalAmount: widget.totalAmount,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Enter Shipping Info", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildStepIndicator(step: 2),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTextField(nameController, "Full Name"),
                    _buildTextField(cityController, "City"),
                    _buildTextField(pincodeController, "Pincode", keyboardType: TextInputType.number),
                    _buildTextField(addressController, "Full Address", maxLines: 3),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: proceedToPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Proceed to Payment", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value == null || value.trim().isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _buildStepIndicator({required int step}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _stepItem("BAG", step == 1),
          _divider(),
          _stepItem("ADDRESS", step == 2),
          _divider(),
          _stepItem("PAYMENT", step == 3),
        ],
      ),
    );
  }

  Widget _stepItem(String label, bool isActive) {
    return Text(
      label,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: isActive ? Colors.indigo : Colors.grey,
      ),
    );
  }

  Widget _divider() {
    return const Text("———", style: TextStyle(color: Colors.grey));
  }
}
