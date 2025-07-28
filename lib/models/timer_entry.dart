import 'dart:async';

class TimerEntry {
  String label;
  Duration duration;
  late DateTime endTime;
  late Timer countdownTimer;

  TimerEntry({required this.label, required this.duration});
}
