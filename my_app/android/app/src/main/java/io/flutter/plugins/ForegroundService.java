package com.example.my_app;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;
import android.net.Uri;
import android.app.PendingIntent; // For creating pending intents
import android.media.AudioAttributes; // For handling audio attributes
import android.content.Context; // For context-based calls

public class ForegroundService extends Service {
    private static final String CHANNEL_ID = "CrashDetectionService";

    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannel();

        // Intent to open the app when the notification is clicked
        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(
            this,
            0,
            notificationIntent,
            PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT
        );

        // Build the notification
        Notification notification = new Notification.Builder(this, CHANNEL_ID)
                .setContentTitle("Crash Detected!!!")
                .setContentText("Crash detected! Making emergency call.")
                .setSmallIcon(R.drawable.ic_notification) // Replace with your app's icon
                .setOngoing(false) // Prevent swiping away the notification
                .setPriority(Notification.PRIORITY_HIGH) // Ensure high visibility
                .setCategory(Notification.CATEGORY_ALARM) // Mark it as an alarm category
                .setVisibility(Notification.VISIBILITY_PUBLIC) // Show on lock screen
                .setSound(android.provider.Settings.System.DEFAULT_ALARM_ALERT_URI) // Custom alarm sound
                .setContentIntent(pendingIntent) // Open app when clicked
                .build();

        // Start the service in the foreground with the notification
        startForeground(1, notification);
    }


    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d("ForegroundService", "Service started");
        makeEmergencyCall(intent.getStringExtra("contact"));
        return START_NOT_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    "Crash Detection Service",
                    NotificationManager.IMPORTANCE_HIGH
            );

            channel.setDescription("Alerts for crash detection.");
            channel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC); // Ensure visibility on lock screen

            // Configure sound
            channel.setSound(
            android.provider.Settings.System.DEFAULT_ALARM_ALERT_URI, // Default alarm sound
            new AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM) // Set the sound usage to alarm
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION) // Mark it as a sonification
                .build()
            );


            // Enable vibration with a custom pattern
            channel.enableVibration(true);
            channel.setVibrationPattern(new long[]{0, 1000, 500, 1000});

            // Register the channel with the system
            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(channel);
            }
        }
    }



    private void makeEmergencyCall(String contact) {
        Intent callIntent = new Intent(Intent.ACTION_CALL);
        callIntent.setData(Uri.parse("tel:" + contact));
        callIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(callIntent);
    }

    // private void makeEmergencyCall(String contact) {
    //     if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
    //         if (checkSelfPermission(android.Manifest.permission.CALL_PHONE) == PackageManager.PERMISSION_GRANTED) {
    //             Intent callIntent = new Intent(Intent.ACTION_CALL);
    //             callIntent.setData(Uri.parse("tel:" + contact));
    //             callIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    //             startActivity(callIntent);
    //         } else {
    //             Log.e("ForegroundService", "CALL_PHONE permission not granted");
    //         }
    //     } else {
    //         Intent callIntent = new Intent(Intent.ACTION_CALL);
    //         callIntent.setData(Uri.parse("tel:" + contact));
    //         callIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    //         startActivity(callIntent);
    //     }
    // }
}
