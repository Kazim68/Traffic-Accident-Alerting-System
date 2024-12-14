import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // Import path_provider for file paths
import 'dart:io'; // Import for file operations

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({super.key});

  @override
  _EmergencyContactScreenState createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  String emergencyContact = "1122"; // Default emergency contact
  final TextEditingController _controller = TextEditingController();
  late File contactFile; // File to store the emergency contact

  @override
  void initState() {
    super.initState();
    _initializeContactFile(); // Initialize and load contact from file
  }

  /// Initialize the contact file and load the stored emergency contact.
  Future<void> _initializeContactFile() async {
    try {
      // Get the app's directory
      final directory = await getApplicationDocumentsDirectory();
      contactFile = File('${directory.path}/emergency_contact.txt');

      if (await contactFile.exists()) {
        // If the file exists, read the stored emergency contact
        String storedContact = await contactFile.readAsString();
        setState(() {
          emergencyContact = storedContact;
        });
      } else {
        // If the file doesn't exist, create it with the default emergency contact
        await contactFile.writeAsString(emergencyContact);
      }
    } catch (e) {
      print('Error initializing contact file: $e');
    }
  }

  /// Save the emergency contact to the file
  Future<void> _saveContactToFile(String contact) async {
    try {
      await contactFile.writeAsString(contact); // Write the contact to the file
    } catch (e) {
      print('Error saving contact to file: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Emergency Contact',
          style: TextStyle(color: Colors.green),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.green),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // Display the current emergency contact
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                emergencyContact,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            // TextField for editing emergency contact
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter new emergency contact',
                hintStyle: TextStyle(color: Colors.green),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            // Change button
            ElevatedButton(
              onPressed: () async {
                String newContact = _controller.text.trim();
                if (newContact.isNotEmpty) {
                  setState(() {
                    emergencyContact = newContact; // Update contact in UI
                  });
                  await _saveContactToFile(newContact); // Save to file
                  _controller.clear(); // Clear input field
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Emergency contact updated!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Contact cannot be empty.")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Change',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
