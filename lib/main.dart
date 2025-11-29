import 'package:flutter/material.dart';
import 'views/splash_screen.dart';
import 'views/login_screen.dart';
import 'views/home_screen.dart';
import 'views/signup_screen.dart';
import 'globals.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'Yuji Home',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const SignupScreen()
      },
    );
  }
}
