import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import './sos_alert_screen.dart';
import 'dart:math';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CrashDetectionScreen(),
    );
  }
}

class CrashDetectionScreen extends StatefulWidget {
  @override
  _CrashDetectionScreenState createState() => _CrashDetectionScreenState();
}

class _CrashDetectionScreenState extends State<CrashDetectionScreen> {
  double x = 0.0, y = 0.0, z = 0.0; // Accelerometer values
  double threshold = 15.0; // Threshold for crash detection (m/s²)
  int crashCount = 0; // Counter for significant changes
  int crashDetectionWindow = 5; // Number of significant changes to detect a crash
  Duration timeWindow = Duration(seconds: 2); // Time window to monitor changes

  List<DateTime> significantChanges = []; // Timestamps of significant changes

  @override
  void initState() {
    super.initState();

    // Listen to accelerometer events
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        x = event.x;
        y = event.y;
        z = event.z;
      });

      // Calculate the resultant acceleration
      double resultantAcceleration = calculateResultantAcceleration(x, y, z);

      // Detect sudden changes
      if (resultantAcceleration > threshold) {
        significantChanges.add(DateTime.now());
        cleanOldTimestamps(); // Remove old timestamps outside the time window

        // Check if the crash detection logic is triggered
        if (significantChanges.length >= crashDetectionWindow) {
          navigateToSOSAlert();
        }
      }
    });
  }

  double calculateResultantAcceleration(double x, double y, double z) {
    return sqrt((x * x + y * y + z * z));
  }

  void cleanOldTimestamps() {
    significantChanges.removeWhere((timestamp) {
      return DateTime.now().difference(timestamp) > timeWindow;
    });
  }

  void navigateToSOSAlert() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SOSAlertScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crash Detection"),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Monitoring Accelerometer Values...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('X: ${x.toStringAsFixed(2)}'),
            Text('Y: ${y.toStringAsFixed(2)}'),
            Text('Z: ${z.toStringAsFixed(2)}'),
            SizedBox(height: 20),
            Text(
              'Threshold: $threshold m/s²',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

