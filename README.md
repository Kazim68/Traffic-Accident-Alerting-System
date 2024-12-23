# Traffic Accident Detection and Alerting System

## Problem Statement
With the rising number of road accidents worldwide, timely assistance is critical to saving lives. Current systems often suffer from delays in notifying emergency services, leading to increased fatalities. Our project addresses this issue by providing a solution to detect accidents in real-time and alert emergency contacts instantly.

## Project Overview
The **Traffic Accident Detection and Alerting System** is a mobile application designed to detect accidents using accelerometer data from smartphones. Upon detecting an accident, the app:
- Automatically makes a call to an emergency contact.
- Sends an SMS with the user's location, even in offline conditions.
- Provides a 10-second SOS timer allowing the user to cancel false alerts.

By leveraging advanced algorithms, such as gravity filtering and time-window validation, the app minimizes false positives and ensures reliable operation in the background.

## Methodology

### Data Sources
1. **Accelerometer Data**: Captured in real-time to identify abrupt motion changes indicative of a crash.
2. **Emergency Contact**: A locally stored contact number for notifications.
3. **GPS Location**: Used to send the user's location with SMS alerts.

### Algorithm
The accident detection system uses a **threshold-based algorithm** with the following steps:

### Gravity Filtering
1. **Gravity Filtering**: Removes noise and gravity components from raw accelerometer data to isolate linear motion.  
   - **Equation**:  
     ```
     g[i] = α * g[i-1] + (1 - α) * a[i]
     a_linear = a - g
     ```

### Resultant Acceleration
2. **Resultant Acceleration**: Calculated as the vector magnitude of filtered acceleration values.  
   - **Equation**:  
     ```
     R = √(a_x² + a_y² + a_z²)
     ```

3. **Crash Detection**: Compares \( R \) with a predefined threshold and tracks significant changes over a 2-second window.
4. **Emergency Workflow**: If a crash is detected:
   - A 10-second timer starts.
   - If not canceled, an emergency call and SMS are initiated.

### Emergency Workflow
1. **Immediate Alert**: The app notifies the emergency contact via call and SMS after the timer expires.
2. **Offline Capability**: SMS can be sent without internet access.
3. **Custom Notifications**: Ensures visibility with alarms and vibrations.

## Tools and Technologies
- **Flutter**: Cross-platform development framework.
- **Dart**: Programming language for app functionality.
- **Sensors**: Accelerometer for crash detection.
- **Android SDK**: For implementing foreground services and notifications.
- **Permissions Handling**: Ensures secure and smooth functionality.

## Wireframes

<table>
  <tr>
    <td align="center">
      <strong>Home Screen</strong><br>
      <img src="https://github.com/user-attachments/assets/a7995462-2229-453c-b86b-eb7067d6fcfe" alt="Home Screen" width="300">
    </td>
    <td align="center">
      <strong>SOS Alert Screen</strong><br>
      <img src="https://github.com/user-attachments/assets/0a6dbbf6-880b-47e6-879d-df8056205d15" alt="SOS Alert Screen" width="300">
    </td>
  </tr>
</table>

 


## Team Members
- **Abdur Rehman Kazim**  
  Roll Number: 2022-CS-115  
- **Sami Ullah**  
  Roll Number: 2022-CS-143  

## Conclusion
The **Traffic Accident Detection and Alerting System** is a step forward in reducing road accident fatalities by ensuring timely alerts and assistance. By integrating advanced algorithms with user-friendly functionality, the app significantly enhances road safety and aligns with global SDGs for health and safety.
