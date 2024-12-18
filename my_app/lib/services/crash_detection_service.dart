import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';
import 'dart:async';
import '../sos_alert_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io'; // For file handling
import 'package:path_provider/path_provider.dart'; // For accessing app directories
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:telephony/telephony.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:background_sms/background_sms.dart';

class CrashDetectionService {
  static const MethodChannel _methodChannel =
      MethodChannel('foregroundServiceChannel');

  void makeEmergencyCallInForeground(String contact) {
    _methodChannel.invokeMethod('startForegroundService', {"contact": contact});
  }

  double threshold = 15.0; // Threshold for crash detection (m/s²)
  int crashDetectionWindow =
      5; // Number of significant changes to detect a crash
  Duration timeWindow = Duration(seconds: 2); // Time window to monitor changes
  List<DateTime> significantChanges = []; // Timestamps of significant changes
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late StreamSubscription<AccelerometerEvent> _subscription;

  double previousX = 0.0, previousY = 0.0, previousZ = 0.0;
  double alpha =
      0.8; // Smoothing factor, you can adjust it to control the sensitivity
  List<double> mGravity = [0.0, 0.0, 0.0];
  int moveCount = 0;
  int startTime = 0;
  int timerValue = 10; // Shared timer value
  late Timer countdownTimer;
  String emergencyContact = "03444571722"; // Default emergency contact number
  late File contactFile;
  ValueNotifier<int> timerNotifier =
      ValueNotifier<int>(10); // Initial timer value

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

  CrashDetectionService(BuildContext context) {
    _loadEmergencyContact();
    checkPermissions();
    _initializeNotifications(context);
  }

  Future<void> checkPermissions() async {
    await [
      Permission.phone,
      Permission.sms,
      Permission.locationWhenInUse,
    ].request();

    if (await Permission.phone.isGranted) {
      print("CALL_PHONE permission granted");
    } else {
      print("CALL_PHONE permission denied");
      await Permission.phone.request();
    }
  }

  void _initializeNotifications(BuildContext context) {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == 'CRASH_ALERT') {
          // Open SOS Alert Screen
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SOSAlertScreen(
                      timerValue: timerValue,
                      stopTimerCallback: stopEmergencyTimer,
                      timerNotifier: timerNotifier, // Pass the notifier
                    )),
          );
        }
      },
    );
  }

  Future<void> _loadEmergencyContact() async {
    try {
      // Get the app's directory
      final directory = await getApplicationDocumentsDirectory();
      contactFile = File('${directory.path}/emergency_contact.txt');

      if (await contactFile.exists()) {
        // If the file exists, read the stored emergency contact
        String storedContact = await contactFile.readAsString();
        emergencyContact = storedContact.trim(); // Save to class variable
      } else {
        // If the file doesn't exist, create it with the default emergency contact
        await contactFile.writeAsString(emergencyContact);
      }
    } catch (e) {
      print('Error initializing contact file: $e');
    }
  }

  void stopEmergencyTimer() {
    if (countdownTimer.isActive) {
      countdownTimer.cancel();
      print("Emergency timer canceled.");
    }
  }

  // final Telephony telephony = Telephony.instance;
  // void sendSMS(String message, String contact) async {
  //   // Added try-catch for error handling
  //   bool permissionsGranted = await telephony.requestSmsPermissions ?? false;
  //   if (permissionsGranted) {
  //     try {
  //       await telephony.sendSms(
  //         to: contact,
  //         message: message,
  //       );
  //       print("SMS sent successfully to $contact.");
  //     } catch (e) {
  //       print("Failed to send SMS: $e");
  //     }
  //   } else {
  //     print("SMS permission not granted.");
  //   }
  // }

  Future<bool> isInternetAvailable() async {
    // Added error handling
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi;
    } catch (e) {
      print("Error checking internet connectivity: $e");
      return false;
    }
  }

  Future<Position?> getCurrentLocation() async {
    // Added this function for location fetching
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      return null;
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void startEmergencyTimer(BuildContext context) {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (timerValue > 0) {
        timerValue--;
        timerNotifier.value = timerValue; // Notify listeners of the change
      } else {
        timer.cancel();
        timerNotifier.dispose();
        //makeEmergencyCall();
        // message

        // Check internet availability
        bool hasInternet = await isInternetAvailable();

        // Fetch location if internet is available
        String message;
        if (hasInternet) {
          Position? position = await getCurrentLocation();
          if (position != null) {
            message =
                "I have had an accident. My location is: (${position.latitude}, ${position.longitude}).";
          } else {
            message = "I have had an accident. Please call me!";
          }
        } else {
          message = "I have had an accident. Track me!";
        }

        // Send SMS
        SmsStatus result = await BackgroundSms.sendMessage(
            phoneNumber: emergencyContact, message: message);
        if (result == SmsStatus.sent) {
          print("Sent");
        } else {
          print("Failed");
        }
        makeEmergencyCallInForeground(emergencyContact);
      }
    });

    // Navigate to SOSAlertScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SOSAlertScreen(
          timerValue: timerValue,
          stopTimerCallback: stopEmergencyTimer,
          timerNotifier: timerNotifier, // Pass the notifier
        ),
      ),
    );
  }

// Make a phone call to the emergency contact
  void makeEmergencyCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: emergencyContact);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      print("Error making call: $e");
    }
  }

  Future<void> _sendCrashNotification(BuildContext context) async {
    final androidDetails = AndroidNotificationDetails(
      'crash_channel',
      'Crash Detection',
      channelDescription: 'Alerts for crash detection',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true, // Enable vibration
      vibrationPattern:
          Int64List.fromList([0, 1000, 500, 1000]), // Custom pattern
      visibility: NotificationVisibility.public, // Visible on lock screen
      fullScreenIntent: true, // Opens the app directly
      sound: RawResourceAndroidNotificationSound('alarm'), // Custom alarm sound
    );

    final details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      'Crash Detected',
      'Tap to open SOS Alert screen.',
      details,
      payload: 'CRASH_ALERT',
    );
  }

  void startListeningForCrashes(BuildContext context) {
    _subscription = accelerometerEvents.listen((event) {
      double resultantAcceleration =
          calculateFilteredAcceleration(event.x, event.y, event.z);

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

          if (moveCount > 5) {
            // Adjust movement count threshold
            //_sendCrashNotification(context);
            timerValue = 10;
            _sendCrashNotification(context);
            startEmergencyTimer(context);
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
  // void navigateToSOSAlert(BuildContext context) {
  //   stopListening(); // Stop the listener to prevent duplicate navigation
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => SOSAlertScreen(timerValue: timerValue)),
  //   );
  // }
}
