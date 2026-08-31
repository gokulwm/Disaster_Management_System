import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class ForegroundService {
  static final ForegroundService _instance = ForegroundService._internal();
  factory ForegroundService() => _instance;
  ForegroundService._internal();

  Future<void> initForegroundTask() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'disasterlink_channel_id',
        channelName: 'DisasterLink Relay Service',
        channelDescription: 'Keeps Bluetooth relay running in background',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<void> startForegroundService() async {
    if (await FlutterForegroundTask.isRunningService) return;
    
    await FlutterForegroundTask.startService(
      notificationTitle: 'DisasterLink Active',
      notificationText: 'Bluetooth relay running',
    );
  }

  Future<void> stopForegroundService() async {
    await FlutterForegroundTask.stopService();
  }
}
