import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/timer_entry.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      notificationChannelId: 'timer_service',
      initialNotificationTitle: 'Chronomancer Timer Running',
      initialNotificationContent: 'Your timers are active',
    ),
    iosConfiguration: IosConfiguration(),
  );

  await service.startService();
}

// Called when service is started
@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.on('stopService').listen((_) {
      service.stopSelf();
    });

    service.setAsForegroundService();
  }

  // Initialize Hive
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  // Register your TimerEntry adapter if not registered
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TimerEntryAdapter());
  }

  // Open the Hive box for timers
  final timersBox = await Hive.openBox<TimerEntry>('timers');

  // Run the timer tick loop every second
  Timer.periodic(Duration(seconds: 1), (_) async {
    int totalSecondsRemaining = 0;
    int runningCount = 0;

    for (int i = 0; i < timersBox.length; i++) {
      final timer = timersBox.getAt(i);
      if (timer != null && timer.isRunning && timer.remainingSeconds > 0) {
        timer.remainingSeconds--;

        totalSecondsRemaining += timer.remainingSeconds;
        runningCount++;

        // Chaining logic if timer.remainingSeconds == 0
        if (timer.remainingSeconds == 0 && timer.nextTimerId != null) {
          // Stop current timer
          timer.isRunning = false;

          final nextTimerKey = int.tryParse(timer.nextTimerId!);
          if (nextTimerKey != null && timersBox.containsKey(nextTimerKey)) {
            final nextTimer = timersBox.get(nextTimerKey);
            if (nextTimer != null) {
              nextTimer.isRunning = true;
              nextTimer.remainingSeconds = nextTimer.originalSeconds;
              await nextTimer.save();
            }
          }
        }
        await timer.save();
      }
    }

    // ⏱️ Update the foreground notification (Android only)
    if (service is AndroidServiceInstance && await service.isForegroundService()) {
      final humanTime = Duration(seconds: totalSecondsRemaining).toString().split('.').first;
      service.setForegroundNotificationInfo(
        title: 'Chronomancer Timers',
        content: '$runningCount running – $humanTime remaining',
      );
      /*
      service.invoke('updateNotification', {
        'runningCount': runningCount,
        'totalSeconds': totalSecondsRemaining,
      });
       */
    }
  });
}
