package com.jayowiee.binqr

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(
			flutterEngine.dartExecutor.binaryMessenger,
			"com.binqr/brightness"
		).setMethodCallHandler { call, result ->
			if (call.method == "setBrightness") {
				val brightness = call.argument<Double>("brightness")?.toFloat() ?: -1f
				val lp = window.attributes
				lp.screenBrightness = brightness
				window.attributes = lp
				result.success(null)
			} else {
				result.notImplemented()
			}
		}
	}
}
