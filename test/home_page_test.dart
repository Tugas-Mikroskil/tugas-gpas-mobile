import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:tugas_mobile_backend/auth/login_page.dart';
import 'package:tugas_mobile_backend/main-page/car_details_page.dart';
import 'package:tugas_mobile_backend/main-page/help_page.dart';
import 'package:tugas_mobile_backend/main-page/home_page.dart';

@GenerateMocks([Dio])
void main() {
  group('HomePage Widget Tests', () {
    testWidgets('Filters car list based on search input',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomePage()));

      // Wait for the API data to load
      await tester.pumpAndSettle();

      // Enter text in search bar
      await tester.enterText(find.byType(TextFormField), 'Car Name');

      // Trigger the filtering
      await tester.pumpAndSettle();

      // Check if filtered results are displayed
      expect(find.text('Car Name'), findsWidgets);
    });

    testWidgets('Displays empty state when no cars match the search query',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomePage()));

      // Wait for the API data to load
      await tester.pumpAndSettle();

      // Enter text in search bar that doesn’t match any car
      await tester.enterText(find.byType(TextFormField), 'Nonexistent Car');

      // Trigger the filtering
      await tester.pumpAndSettle();

      // Check if empty state message is displayed
      expect(find.text('Car is empty'), findsOneWidget);
    });

    test('Formats price correctly', () {
      final carListItem = CarListItem(car: {'price': '1200000'});

      // Test the formatPrice function
      expect(carListItem.formatPrice('1200000'), 'Rp 1.200.000');
    });
    testWidgets('Navigates to HelpPage when help icon is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomePage()));

      // Tap on help button
      await tester.tap(find.byIcon(Icons.help));

      // Wait for navigation to complete
      await tester.pumpAndSettle();

      // Check if HelpPage is displayed
      expect(find.byType(HelpPage), findsOneWidget);
    });
  });
}
