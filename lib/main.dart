import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tugas_mobile_backend/auth/login_page.dart';
import 'package:tugas_mobile_backend/auth/register_page.dart';
import 'package:tugas_mobile_backend/home/home_page.dart';
import 'package:tugas_mobile_backend/home/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          initialRoute: snapshot.data == true ? '/home' : '/login',
          routes: {
            '/home': (context) => HomePage(),
            '/login': (context) => LoginPage(),
            '/register': (context) => RegisterPage(),
            '/settings': (context) => SettingsPage(),
          },
        );
      },
    );
  }
}
