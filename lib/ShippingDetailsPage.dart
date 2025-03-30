import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'OrderConfirmationPage.dart';

class ShippingDetailsPage extends StatefulWidget {
  final double totalAmount;

  ShippingDetailsPage({required this.totalAmount});

  @override
  _ShippingDetailsPageState createState() => _ShippingDetailsPageState();
}

class _ShippingDetailsPageState extends State<ShippingDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  String name = "", doorNumber = "", street = "", city = "", state = "", pincode = "", phone = "", altPhone = "";
  String paymentMethod = "Cash on Delivery"; // Default Payment Method

  void saveShippingDetails() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String userId = auth.currentUser?.uid ?? "";
      if (userId.isEmpty) return;

      // Save shipping details to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).collection('orders').add({
        'name': name,
        'doorNumber': doorNumber,
        'street': street,
        'city': city,
        'state': state,
        'pincode': pincode,
        'phone': phone,
        'altPhone': altPhone,
        'totalAmount': widget.totalAmount,
        'paymentMethod': paymentMethod,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Processing',
      });

      // Navigate directly to Order Confirmation Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationPage(
            totalAmount: widget.totalAmount,
            name: name,
            address: "$doorNumber, $street, $city, $state - $pincode",
           
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shipping Details")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Full Name"),
                validator: (value) => value!.isEmpty ? "Enter your name" : null,
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Door Number"),
                validator: (value) => value!.isEmpty ? "Enter your door number" : null,
                onSaved: (value) => doorNumber = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Street Address"),
                validator: (value) => value!.isEmpty ? "Enter your street address" : null,
                onSaved: (value) => street = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "City"),
                validator: (value) => value!.isEmpty ? "Enter your city" : null,
                onSaved: (value) => city = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "State"),
                validator: (value) => value!.isEmpty ? "Enter your state" : null,
                onSaved: (value) => state = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Pincode"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.length != 6 ? "Enter a valid pincode" : null,
                onSaved: (value) => pincode = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.length < 10 ? "Enter a valid phone number" : null,
                onSaved: (value) => phone = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Alternate Phone Number (Optional)"),
                keyboardType: TextInputType.phone,
                onSaved: (value) => altPhone = value ?? "",
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveShippingDetails,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, minimumSize: Size(double.infinity, 50)),
                child: Text("Proceed", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
