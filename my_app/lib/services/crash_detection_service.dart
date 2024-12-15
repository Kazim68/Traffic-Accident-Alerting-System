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
      0.8; // Smoothing factor, you can adjust it to control the sensitivity
  List<double> mGravity = [0.0, 0.0, 0.0];
  int moveCount = 0;
  int startTime = 0;

  double calculateFilteredAcceleration(double x, double y, double z) {
    // Gravity components
    mGravity[0] = alpha * mGravity[0] + (1 - alpha) * x;
    mGravity[1] = alpha * mGravity[1] + (1 - alpha) * y;
    mGravity[2] = alpha * mGravity[2] + (1 - alpha) * z;

    // Linear acceleration (removing gravity)
    double linearX = x - mGravity[0];
    double linearY = y - mGravity[1];
    double linearZ = z - mGravity[2];

    // Calculate resultant linear acceleration
    return sqrt(linearX * linearX + linearY * linearY + linearZ * linearZ);
  }

void startListeningForCrashes(BuildContext context) {
  _subscription = accelerometerEvents.listen((event) {
    double resultantAcceleration = calculateFilteredAcceleration(event.x, event.y, event.z);

    if (resultantAcceleration > threshold) {
      int now = DateTime.now().millisecondsSinceEpoch;

      if (startTime == 0) {
        startTime = now;
      }

      int elapsedTime = now - startTime;

      if (elapsedTime > timeWindow.inMilliseconds) {
        // Reset logic if too much time has passed without sufficient movements
        resetShakeDetection();
      } else {
        moveCount++;

        if (moveCount > 5) { // Adjust movement count threshold
          navigateToSOSAlert(context);
          resetShakeDetection();
        }
      }
    }
  });
}

void resetShakeDetection() {
  moveCount = 0;
  startTime = 0;
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
