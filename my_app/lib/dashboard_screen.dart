import 'package:flutter/material.dart';
import '../emergency_contact_screen.dart';
import '../sos_alert_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.green)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image widget for the illustration
            Image.asset(
              'assets/images/car_accident.png', // Place your image in assets/images folder
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20), // Add spacing
            // Emergency Contact button
            ElevatedButton(
              onPressed: () {
                // Navigate to Emergency Contact Screen
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
                  'Emergency contact',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20), // Add spacing
            // SOS Alert button
            ElevatedButton(
              onPressed: () {
                // Navigate to SOS Alert Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SOSAlertScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Text(
                  'SOS Alert',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white, // Background color of the screen
    );
  }
}
