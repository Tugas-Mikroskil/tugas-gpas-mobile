import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tugas_mobile_backend/main-page/car_details_page.dart';

void main() {
  group('CarDetails Widget Tests', () {
    // Sample car data for testing
    final carData = {
      'id': 1,
      'name': 'Toyota Hilux',
      'price': '250000000',
      'seats': '5',
      'type': 'Pickup',
      'description': 'A rugged and reliable pickup truck.',
      'image': 'hilux.jpg',
      'gallery': ['hilux1.jpg', 'hilux2.jpg'],
    };

    testWidgets('Renders CarDetails widget without errors',
        (WidgetTester tester) async {
      // Build the CarDetails widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarDetails(car: carData),
          ),
        ),
      );

      // Verify that the widget renders without errors
      expect(find.byType(CarDetails), findsOneWidget);
    });

    testWidgets('Displays correct car name and price',
        (WidgetTester tester) async {
      // Build the CarDetails widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarDetails(car: carData),
          ),
        ),
      );

      // Wait for the widget to fully load
      await tester.pumpAndSettle();

      // Verify the car name is displayed correctly
      expect(find.text('Toyota Hilux'), findsWidgets);

      // Verify the car price is displayed correctly
      expect(find.text('Rp 250.000.000'), findsWidgets);
    });

    testWidgets('Displays correct car description',
        (WidgetTester tester) async {
      // Build the CarDetails widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarDetails(car: carData),
          ),
        ),
      );

      // Wait for the widget to fully load
      await tester.pumpAndSettle();

      // Verify the car description is displayed correctly
      expect(find.text('A rugged and reliable pickup truck.'), findsOneWidget);
    });
  });
}
