import 'package:flutter/services.dart';

class BrightnessUtil {
  static const _channel = MethodChannel('com.binqr/brightness');

  static Future<void> setMax() async {
    try {
      await _channel.invokeMethod('setBrightness', {'brightness': 1.0});
    } catch (_) {}
  }

  static Future<void> restore() async {
    try {
      await _channel.invokeMethod('setBrightness', {'brightness': -1.0});
    } catch (_) {}
  }
}