package com.example.my_app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "foregroundServiceChannel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "startForegroundService") {
                    val contact: String? = call.argument("contact")
                    val intent = Intent(this, ForegroundService::class.java)
                    intent.putExtra("contact", contact)
                    startService(intent)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }
}
