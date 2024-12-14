import 'package:flutter/material.dart';
import 'dashboard_screen.dart'; // Import the DashboardScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dashboard App',
      theme: ThemeData(
        // Using the theme provided in the second snippet
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Set DashboardScreen as the home screen
      home: DashboardScreen(),
    );
  }
}
