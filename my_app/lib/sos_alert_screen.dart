import 'package:flutter/material.dart';
import 'dart:async';

class SOSAlertScreen extends StatefulWidget {
  const SOSAlertScreen({super.key});

  @override
  _SOSAlertScreenState createState() => _SOSAlertScreenState();
}

class _SOSAlertScreenState extends State<SOSAlertScreen> {
  int timer = 10;
  late Timer countdownTimer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (this.timer > 0) {
        setState(() {
          this.timer--;
        });
      } else {
        // Timer ends, perform auto-call action
        timer.cancel();
        showAutoCallMessage();
      }
    });
  }

  void showAutoCallMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Calling Emergency Contact"),
        content: Text("Ringing alert notification..."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    countdownTimer.cancel();
    super.dispose();
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
            // SOS Cancel Button
            ElevatedButton(
              onPressed: () {
                countdownTimer.cancel();
                Navigator.pop(context); // Go back to previous screen
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
            // Timer Display
            Text(
              timer.toString(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}