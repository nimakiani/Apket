package com.example.sendapp

import android.content.pm.PackageManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "apk_share_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getApkPath") {
                    val packageName = call.argument<String>("packageName")
                    try {
                        val pm = applicationContext.packageManager
                        val info = pm.getApplicationInfo(packageName!!, 0)
                        result.success(info.sourceDir)
                    } catch (e: PackageManager.NameNotFoundException) {
                        result.error("NOT_FOUND", "App not found", null)
                    }
                }
            }
    }
}