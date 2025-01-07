import 'package:flutter/material.dart';
import 'package:tugas_mobile_backend/main-page/checkout_page.dart';

class CarDetails extends StatefulWidget {
  final dynamic car;

  const CarDetails({required this.car});

  @override
  State<CarDetails> createState() => _CarDetailsState();
}

class _CarDetailsState extends State<CarDetails> {
  int _currentIndex = 0;

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
    final List<String> gallery = [
      widget.car['image'],
      ...widget.car['gallery']
    ];
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.car['name'] ?? 'Car Details',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Carousel
                  SizedBox(
                    height: 260,
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            itemCount: gallery.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Image.network(
                                'http://192.168.1.8:3000/car/image/${gallery[index]}',
                                width: screenWidth,
                                height: 240,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: screenWidth,
                                    height: 240,
                                    color: Colors.grey[800],
                                    child: const Center(
                                      child: Icon(Icons.car_repair,
                                          color: Colors.white, size: 48),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(gallery.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentIndex == index ? 12 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentIndex == index
                                    ? Colors.orange
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.car['name'] ?? 'Unknown Car',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatPrice(widget.car['price'] ?? '0'),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.event_seat,
                          color: Colors.white54, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Seats: ${widget.car['seats'] ?? 'N/A'}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.directions_car_filled,
                          color: Colors.white54, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        widget.car['type'] ?? 'N/A',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Divider
                  Divider(
                    color: Colors.grey[700],
                    thickness: 1,
                  ),
                  const SizedBox(height: 16),
                  // Car Description
                  Text(
                    'Description',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.car['description'] ?? 'No description available.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black.withOpacity(0.9),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Checkout Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutPage(
                          carName: widget.car['name'],
                          carPrice: widget.car['price'],
                          carImage:
                              "http://192.168.1.8:3000/car/image/${widget.car['image']}",
                          carId: widget.car['id'],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 8,
                  ),
                  child: const Text(
                    'Buy Now',
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
    );
  }
}
