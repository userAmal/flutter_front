import 'package:flutter/material.dart';
import 'package:flutter_shop/login.dart';
import 'SignUpPage.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const LoginPage(), // Route pour '/'
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),

        '/home': (context) => const HomePage(
              userId: 0,
            ),
      },
      initialRoute: '/login',
    );
  }
}
