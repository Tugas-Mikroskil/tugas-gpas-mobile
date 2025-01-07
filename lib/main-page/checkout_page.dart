import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class CheckoutPage extends StatefulWidget {
  final String carName;
  final String carPrice;
  final String carImage;
  final int carId;

  const CheckoutPage({
    Key? key,
    required this.carName,
    required this.carPrice,
    required this.carImage,
    required this.carId,
  }) : super(key: key);

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Form controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController daysController = TextEditingController();
  final TextEditingController citizenNumberController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  String formatPrice(String price) {
    final int parsedPrice = int.tryParse(price) ?? 0;
    final List<String> digits = parsedPrice.toString().split('');
    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        formatted += '.';
      }
      formatted += digits[i];
    }
    return 'Rp $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // Car details display
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      widget.carImage,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.carName,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatPrice(widget.carPrice),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                            controller: firstNameController,
                            labelText: 'First Name'),
                        _buildTextField(
                            controller: lastNameController,
                            labelText: 'Last Name'),
                        _buildTextField(
                            controller: addressController,
                            labelText: 'Address'),
                        _buildTextField(
                            controller: phoneController,
                            labelText: 'Phone Number'),
                        _buildTextField(
                            controller: daysController, labelText: 'Days'),
                        _buildTextField(
                            controller: citizenNumberController,
                            labelText: 'Citizen Number'),
                        _buildTextField(
                            controller: destinationController,
                            labelText: 'Destination'),
                        const SizedBox(height: 30),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            color: Colors.black.withOpacity(0.9),
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: ElevatedButton(
                                onPressed: _onCheckoutPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 8,
                                ),
                                child: const Text(
                                  'Proceed To Checkout',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
      backgroundColor: Colors.black,
    );
  }

  // TextFormField builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.orange),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }
          return null;
        },
      ),
    );
  }

  // Checkout button logic
  void _onCheckoutPressed() {
    if (_formKey.currentState!.validate()) {
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            'Confirm Checkout',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to checkout?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.orange),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _checkout(); // Proceed with checkout
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }
  }

  // Handle checkout
  void _checkout() async {
  setState(() {
    isLoading = true;
  });

  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Retrieve the token from SharedPreferences
  String? token = prefs.getString('token');

  // Prepare the data to send to the backend
  final Map<String, dynamic> orderData = {
    "firstName": firstNameController.text,
    "lastName": lastNameController.text,
    "days": int.tryParse(daysController.text) ?? 0,
    "carId": widget.carId,
    "phoneNumber": phoneController.text,
    "citizenNumber": citizenNumberController.text,
    "address": addressController.text,
    "destination": destinationController.text,
    "userId": token,
  };

  try {
    // Send the POST request
    final response = await http.post(
      Uri.parse('http://192.168.1.8:3000/order'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(orderData),
    );

    // Check the response status
    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });

      // Show success message using Awesome Notifications
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'basic_channel',
          title: 'Order Successful',
          body: 'Your order for ${widget.carName} has been successfully placed!',
          backgroundColor: Colors.black,
          notificationLayout: NotificationLayout.Default,
        ),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully checked out!')),
      );

      // Navigate back to HomePage
      Navigator.pop(context); // Close the CheckoutPage
      Navigator.pop(context); // Navigate back to the HomePage
    } else {
      setState(() {
        isLoading = false;
      });

      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.statusCode}')),
      );
    }
  } catch (error) {
    setState(() {
      isLoading = false;
    });

    // Handle network error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Network error, please try again later.')),
    );
  }
}
}
