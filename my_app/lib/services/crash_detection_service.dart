import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'dart:async';
import '../sos_alert_screen.dart';

class CrashDetectionService {
  double threshold = 15.0; // Threshold for crash detection (m/s²)
  int crashDetectionWindow =
      5; // Number of significant changes to detect a crash
  Duration timeWindow = Duration(seconds: 2); // Time window to monitor changes
  List<DateTime> significantChanges = []; // Timestamps of significant changes

  late StreamSubscription<AccelerometerEvent> _subscription;

  double previousX = 0.0, previousY = 0.0, previousZ = 0.0;
  double alpha =
      0.1; // Smoothing factor, you can adjust it to control the sensitivity

  double calculateFilteredAcceleration(double x, double y, double z) {
    // Apply exponential smoothing
    double filteredX = alpha * x + (1 - alpha) * previousX;
    double filteredY = alpha * y + (1 - alpha) * previousY;
    double filteredZ = alpha * z + (1 - alpha) * previousZ;

    // Store the smoothed values for the next iteration
    previousX = filteredX;
    previousY = filteredY;
    previousZ = filteredZ;

    // Calculate the resultant acceleration
    return sqrt(
        filteredX * filteredX + filteredY * filteredY + filteredZ * filteredZ);
  }

  // Start listening for crashes
  void startListeningForCrashes(BuildContext context) {
    _subscription = accelerometerEvents.listen((event) {
      double resultantAcceleration =
          calculateFilteredAcceleration(event.x, event.y, event.z);

      if (resultantAcceleration > threshold) {
        significantChanges.add(DateTime.now());
        cleanOldTimestamps();

        if (significantChanges.length >= crashDetectionWindow) {
          navigateToSOSAlert(context);
        }
      }
    });
  }

  // Stop listening for crashes
  void stopListening() {
    _subscription.cancel();
  }

  // Calculate the resultant acceleration
  double calculateResultantAcceleration(double x, double y, double z) {
    return sqrt(x * x + y * y + z * z);
  }

  void cleanOldTimestamps() {
  significantChanges.removeWhere((timestamp) {
    return DateTime.now().difference(timestamp) > timeWindow;
  });
}


  // Navigate to the SOS Alert screen
  void navigateToSOSAlert(BuildContext context) {
    stopListening(); // Stop the listener to prevent duplicate navigation
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SOSAlertScreen()),
    );
  }
}
