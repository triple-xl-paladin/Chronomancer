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

  /// Field for chaining timers
  @HiveField(5)
  String? nextTimerId;

  TimerEntry({
    required this.label,
    required this.originalSeconds,
    required this.remainingSeconds,
    this.isRunning = false,
    this.groupName,
    this.nextTimerId,
  });

  Duration get originalDuration => Duration(seconds: originalSeconds);
  Duration get remainingDuration => Duration(seconds: remainingSeconds);

  void reset() {
    remainingSeconds = originalSeconds;
    isRunning = false;
  }
}
