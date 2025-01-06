import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> carList = [];
  List<dynamic> filteredCarList = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
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
      Dio dio = Dio();
      final response = await dio.get('http://192.168.1.11:3000/car');

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
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     DropdownButton<String>(
                  //       items: const [
                  //         DropdownMenuItem(
                  //             value: 'Service 1', child: Text('Service 1')),
                  //         DropdownMenuItem(
                  //             value: 'Service 2', child: Text('Service 2')),
                  //       ],
                  //       onChanged: (value) {},
                  //       hint: const Text('Services',
                  //           style: TextStyle(color: Colors.white54)),
                  //       dropdownColor: Colors.grey[850],
                  //       style: const TextStyle(color: Colors.white),
                  //     ),
                  //     DropdownButton<String>(
                  //       items: const [
                  //         DropdownMenuItem(
                  //             value: 'Type 1', child: Text('Type 1')),
                  //         DropdownMenuItem(
                  //             value: 'Type 2', child: Text('Type 2')),
                  //       ],
                  //       onChanged: (value) {},
                  //       hint: const Text('Types',
                  //           style: TextStyle(color: Colors.white54)),
                  //       dropdownColor: Colors.grey[850],
                  //       style: const TextStyle(color: Colors.white),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Image.network(
              'http://192.168.1.11:3000/car/image/${car['image']}',
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
                      fontSize: 18,
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
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Price: ${car['price'] ?? ''}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
