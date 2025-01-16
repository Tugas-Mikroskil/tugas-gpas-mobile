import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_mobile_backend/main-page/car_details_page.dart';
import 'package:tugas_mobile_backend/main-page/help_page.dart';
import 'package:tugas_mobile_backend/main-page/order_history_page.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class HomePage extends StatefulWidget {
  final Dio dio;

  HomePage({required this.dio});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Dio get dio => widget.dio;

  List<dynamic> carList = [];
  List<dynamic> filteredCarList = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    super.initState();
    fetchCars();

    // Listen for changes in the search bar
    searchController.addListener(() {
      filterCars();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchCars() async {
    try {
      final response = await dio.get('http://rein.gpasolution.id/car');

      print(response.data);

      if (response.statusCode == 200) {
        setState(() {
          carList = response.data['data'];
          filteredCarList = carList; // Initially, show all cars
          isLoading = false;
        });
      } else {
        print('Failed to fetch cars. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cars: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterCars() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredCarList = carList;
      } else {
        filteredCarList = carList
            .where((car) => car['name'].toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Car'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushNamed('/settings');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help, color: Colors.white), // Help button
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => HelpPage(), // Navigate to HelpPage
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.history,
                color: Colors.white), // Order History button
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => OrderHistoryPage(),
              ));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search car here',
                      filled: true,
                      fillColor: Colors.grey[850],
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white54),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filteredCarList.isEmpty
                        ? const Center(
                            child: Text(
                              'Car is empty',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredCarList.length,
                            itemBuilder: (context, index) {
                              return CarListItem(car: filteredCarList[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
      backgroundColor: Colors.black,
    );
  }
}

class CarListItem extends StatelessWidget {
  final dynamic car;

  const CarListItem({required this.car});

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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarDetails(car: car),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.grey[850],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Image.network(
                'http://rein.gpasolution.id/car/image/${car['image']}',
                width: 130,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 130,
                    height: 90,
                    color: Colors.grey,
                    child: const Icon(Icons.car_repair, color: Colors.white),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car['name'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Seats: ${car['seats'] ?? ''}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Price: ' + formatPrice(car['price'] ?? '0'),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
