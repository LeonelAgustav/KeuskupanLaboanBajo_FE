import 'package:flutter/services.dart';

class ScreenshotGuard {
  static const _channel = MethodChannel('com.keuskupanlaboanbajo/security');

  static Future<void> setSecure(bool enabled) async {
    try {
      await _channel.invokeMethod('setSecure', enabled);
    } catch (e) {
      // platform unsupported / error (silently ignore)
    }
  }
}
