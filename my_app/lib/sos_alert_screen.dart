import 'package:flutter/material.dart';
import 'package:my_app/dashboard_screen.dart';
import 'dart:async';
import 'dart:io'; // For file handling
import 'package:path_provider/path_provider.dart'; // For accessing app directories
//import 'package:url_launcher/url_launcher.dart';
import "../services/crash_detection_service.dart";

class SOSAlertScreen extends StatefulWidget {
  final int timerValue; // Accept timer value as a parameter
  final VoidCallback stopTimerCallback; // Callback to stop the timer
  final ValueNotifier<int> timerNotifier; // Timer notifier

  const SOSAlertScreen({
    Key? key,
    required this.timerValue,
    required this.stopTimerCallback,
    required this.timerNotifier,
  }) : super(key: key);

  @override
  _SOSAlertScreenState createState() => _SOSAlertScreenState();
}

class _SOSAlertScreenState extends State<SOSAlertScreen> {
  late int displayedTimerValue;
  String emergencyContact = "03444571722"; // Default emergency contact number
  late File contactFile;
  late CrashDetectionService crashDetectionService;

  @override
  void initState() {
    super.initState();
    _loadEmergencyContact(); // Load the emergency contact from the file
    displayedTimerValue = widget.timerValue;
    //startTimer();
  }

  // Load the emergency contact from the file
  Future<void> _loadEmergencyContact() async {
    try {
      // Get the app's directory
      final directory = await getApplicationDocumentsDirectory();
      contactFile = File('${directory.path}/emergency_contact.txt');

      if (await contactFile.exists()) {
        // If the file exists, read the stored emergency contact
        String storedContact = await contactFile.readAsString();
        setState(() {
          emergencyContact = storedContact.trim(); // Trim to avoid extra spaces
        });
      } else {
        // If the file doesn't exist, create it with the default emergency contact
        await contactFile.writeAsString(emergencyContact);
      }
    } catch (e) {
      print('Error initializing contact file: $e');
    }
  }

  // void startTimer() {
  //   countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
  //     if (this.timer > 0) {
  //       setState(() {
  //         this.timer--;
  //       });
  //     } else {
  //       // Timer ends, perform auto-call action
  //       timer.cancel();
  //       makeEmergencyCall();
  //     }
  //   });
  // }

  // // Make a phone call to the emergency contact
  // void makeEmergencyCall() async {
  //   final Uri phoneUri = Uri(scheme: 'tel', path: emergencyContact);

  //   try {
  //     if (await canLaunchUrl(phoneUri)) {
  //       await launchUrl(phoneUri);
  //     } else {
  //       _showErrorDialog("Unable to place the call.");
  //     }
  //   } catch (e) {
  //     print("Error making call: $e");
  //   }
  // }

  // void _showErrorDialog(String message) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text("Error"),
  //       content: Text(message),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text("OK"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  void dispose() {
    //countdownTimer.cancel();
    widget.stopTimerCallback(); // Stop the timer
    crashDetectionService = CrashDetectionService(context);
    crashDetectionService.startListeningForCrashes(context); // Start crash detection
    super.dispose();
  }

  void updateTimer(int newValue) {
    setState(() {
      displayedTimerValue = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert!', style: TextStyle(color: Colors.red)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Alert!",
              style: TextStyle(
                color: Colors.red,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "You’ve been under an accident. If this is a\nfalse alarm, then cancel the SOS Request.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                widget.stopTimerCallback(); // Call the callback to stop the timer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Button color
                shape: CircleBorder(),
                padding: const EdgeInsets.all(50), // Circle button size
              ),
              child: const Text(
                'SOS\nCancel Request',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ValueListenableBuilder<int>(
              valueListenable: widget.timerNotifier,
              builder: (context, value, child) {
                return Text(
                  value.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
