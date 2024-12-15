import 'package:flutter/material.dart';
import "../services/crash_detection_service.dart";
import './emergency_contact_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late CrashDetectionService crashDetectionService;

  @override
  void initState() {
    super.initState();
    crashDetectionService = CrashDetectionService(context);
    crashDetectionService.startListeningForCrashes(context); // Start crash detection
  }

  @override
  void dispose() {
    crashDetectionService.stopListening(); // Stop crash detection
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Dashboard',
        style: TextStyle(
          color: Colors.green,
          fontSize: 28, // Increased font size
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Shifted the image upwards and increased size
            const SizedBox(height: 10), // Adjust spacing above the image
            Image.asset(
              'assets/images/car_accident.png', // Replace with your project image path
              width: 250, // Increased width
              height: 250, // Increased height
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 20), // Space between the image and description

            // App description
            const Text(
              'This app provides real-time crash detection and SOS alert services. '
              'It ensures safety by immediately notifying your emergency contact in case of accidents.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.green, // Matching the green color scheme
                fontWeight: FontWeight.w500, // Medium weight for better readability
              ),
            ),

            const SizedBox(height: 30), // Space between the description and button

            // Emergency Contact Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmergencyContactScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Text(
                  'Emergency Contact',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    backgroundColor: Colors.white, // Background color
  );
}

}
