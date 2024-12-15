import 'package:flutter/material.dart';
import './dashboard_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crash Detection App',
      home: DashboardScreen(),
    );
  }
}
