package com.guozhigq.vvex

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "vvex/link_settings")
            .setMethodCallHandler { call, result ->
                if (call.method != "openLinkSettings") {
                    result.notImplemented()
                } else {
                    try {
                        val action = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            Settings.ACTION_APP_OPEN_BY_DEFAULT_SETTINGS
                        } else {
                            Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                        }
                        startActivity(Intent(action, Uri.parse("package:$packageName")))
                        result.success(null)
                    } catch (error: Exception) {
                        result.error("LINK_SETTINGS", error.message, null)
                    }
                }
            }
    }
}
