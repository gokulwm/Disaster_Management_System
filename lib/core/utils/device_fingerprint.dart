import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceFingerprint {
  static Future<String> getFingerprint() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedId = prefs.getString('device_fingerprint');
    if (storedId != null) return storedId;

    String newId = '';
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        newId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        newId = iosInfo.identifierForVendor ?? const Uuid().v4();
      } else {
        newId = const Uuid().v4();
      }
    } catch (e) {
      newId = const Uuid().v4();
    }
    
    await prefs.setString('device_fingerprint', newId);
    return newId;
  }
}
