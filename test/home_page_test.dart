import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:tugas_mobile_backend/auth/login_page.dart';
import 'package:tugas_mobile_backend/main-page/car_details_page.dart';
import 'package:tugas_mobile_backend/main-page/help_page.dart';
import 'package:tugas_mobile_backend/main-page/home_page.dart';

import 'home_page_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('HomePage Widget Tests : ', () {
    setUpAll(() async {});
    test('fetch cars successfully', () async {
      final mockDio = MockDio();
      final responseData = {
        'data': [
          {'id': 1, 'name': 'Hilux'}
        ]
      };

      when(mockDio.get('http://rein.gpasolution.id/car')).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      final response = await mockDio.get('http://rein.gpasolution.id/car');
      expect(response.data['data'][0]['name'], 'Hilux');
    });
    testWidgets('Filters car list based on search input',
        (WidgetTester tester) async {
      final mockDio = MockDio();
      final responseData = {
        'data': [
          {'id': 1, 'name': 'Hilux'}
        ]
      };

      // Stub the `get` method with all possible parameters
      when(mockDio.get(
        'http://rein.gpasolution.id/car',
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions:
              RequestOptions(path: 'http://rein.gpasolution.id/car'),
        ),
      );

      // Inject the mocked Dio instance into the HomePage
      await tester.pumpWidget(
        MaterialApp(
          home: HomePage(dio: mockDio),
        ),
      );

      // Wait for the API data to load
      await tester.pumpAndSettle();

      // Enter text in search bar
      await tester.enterText(find.byType(TextFormField), 'Hilux');

      // Trigger the filtering
      await tester.pumpAndSettle();

      // Check if filtered results are displayed
      expect(find.text('Hilux'), findsWidgets);
    });

    testWidgets('Displays empty state when no cars match the search query',
        (WidgetTester tester) async {
      final mockDio = MockDio();
      final responseData = {
        'data': [
          {'id': 1, 'name': 'Hilux'}
        ]
      };

      // Stub the `get` method with all possible parameters
      when(mockDio.get(
        'http://rein.gpasolution.id/car',
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
      )).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions:
              RequestOptions(path: 'http://rein.gpasolution.id/car'),
        ),
      );
      await tester.pumpWidget(MaterialApp(home: HomePage(dio: mockDio)));

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
    testWidgets('Displays loading indicator when fetching cars',
        (WidgetTester tester) async {
      final mockDio = MockDio();

      // Simulate a delayed response
      when(mockDio.get('http://rein.gpasolution.id/car')).thenAnswer(
        (_) async {
          await Future.delayed(Duration(seconds: 2));
          return Response(
            data: {'data': []},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          );
        },
      );

      await tester.pumpWidget(MaterialApp(home: HomePage(dio: mockDio)));

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('Renders all cars in the list', (WidgetTester tester) async {
      final mockDio = MockDio();
      final responseData = {
        'data': [
          {'id': 1, 'name': 'Hilux'},
          {'id': 2, 'name': 'Fortuner'}
        ]
      };

      when(mockDio.get('http://rein.gpasolution.id/car')).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      await tester.pumpWidget(MaterialApp(home: HomePage(dio: mockDio)));
      await tester.pumpAndSettle();

      // Verify both cars are displayed
      expect(find.text('Hilux'), findsOneWidget);
      expect(find.text('Fortuner'), findsOneWidget);
    });

    testWidgets('Displays default image for cars without image URL',
        (WidgetTester tester) async {
      final mockDio = MockDio();
      final responseData = {
        'data': [
          {'id': 1, 'name': 'Hilux', 'image': null}
        ]
      };

      when(mockDio.get('http://rein.gpasolution.id/car')).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      await tester.pumpWidget(MaterialApp(home: HomePage(dio: mockDio)));
      await tester.pumpAndSettle();

      // Verify default image is displayed
      expect(find.byIcon(Icons.car_repair), findsOneWidget);
    });
  });

  testWidgets('Displays message when no cars match search query',
      (WidgetTester tester) async {
    final mockDio = MockDio();
    final responseData = {
      'data': [
        {'id': 1, 'name': 'Hilux'},
      ]
    };

    when(mockDio.get('http://rein.gpasolution.id/car')).thenAnswer(
      (_) async => Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ),
    );

    await tester.pumpWidget(MaterialApp(home: HomePage(dio: mockDio)));
    await tester.pumpAndSettle();

    // Enter search query with no matches
    await tester.enterText(find.byType(TextFormField), 'NonExistentCar');
    await tester.pumpAndSettle();

    // Verify no matching message is displayed
    expect(find.text('Car is empty'), findsOneWidget);
  });
}
