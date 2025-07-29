import 'dart:async';
import 'package:hive/hive.dart';

part 'timer_entry.g.dart';

@HiveType(typeId: 0)
class TimerEntry extends HiveObject {
  @HiveField(0)
  String label;

  @HiveField(1)
  int originalSeconds;

  @HiveField(2)
  int remainingSeconds;

  @HiveField(3)
  bool isRunning;

  @HiveField(4)
  String? groupName;

  TimerEntry({
    required this.label,
    required this.originalSeconds,
    required this.remainingSeconds,
    this.isRunning = false,
    this.groupName,
  });

  Duration get originalDuration => Duration(seconds: originalSeconds);
  Duration get remainingDuration => Duration(seconds: remainingSeconds);

  void reset() {
    remainingSeconds = originalSeconds;
    isRunning = false;
  }
}
