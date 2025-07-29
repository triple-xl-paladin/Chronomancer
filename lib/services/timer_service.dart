import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/timer_entry.dart';

class TimerService {
  final Box<TimerEntry> _box = Hive.box<TimerEntry>('timers');
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<String, Timer> _runningTimers = {};

  TimerService();

  List<TimerEntry> getAllTimers() => _box.values.toList();

  Future<void> addTimer(TimerEntry entry) async {
    await _box.add(entry);
  }

  Future<void> deleteTimer(TimerEntry entry) async {
    await _box.delete(entry);
  }

  Future<void> updateTimer(TimerEntry entry) async {
    await entry.save();
  }

  Future<void> startTimer(TimerEntry entry) async {
    if (entry.isRunning) return;

    entry.isRunning = true;
    await entry.save();
    _tickCountdown(entry);
  }

  void pauseTimer(TimerEntry entry) async {
    if (!entry.isRunning) return;

    entry.isRunning = false;
    await entry.save();

    final key = entry.key.toString();
    if (_runningTimers.containsKey(key)) {
      _runningTimers[key]?.cancel();
      _runningTimers.remove(key);
    }
  }

  void resetTimer(TimerEntry entry) async {
    entry.remainingSeconds = entry.originalSeconds;
    entry.isRunning = false;
    await entry.save();

    final key = entry.key.toString();
    if (_runningTimers.containsKey(key)) {
      _runningTimers[key]?.cancel();
      _runningTimers.remove(key);
    }
  }

  void _tickCountdown(TimerEntry entry) async {
    if (!entry.isRunning) return;

    final key = entry.key.toString();

    _runningTimers[key] = Timer(const Duration(seconds: 1), () async {
      if (!entry.isRunning || !_box.containsKey(entry.key)) {
        _runningTimers[key]?.cancel();
        _runningTimers.remove(key);
        return;
      }

      if (entry.remainingSeconds > 0) {
        entry.remainingSeconds--;
        await entry.save();
        _tickCountdown(entry);
      } else {
        entry.isRunning = false;
        await entry.save();
        _runningTimers[key]?.cancel();
        _runningTimers.remove(key);
        await _playAlarm();
      }
    });
  }

  Future<void> _playAlarm() async {
    await _audioPlayer.play(AssetSource('sounds/alarm.wav'));
  }

  void dispose() {
    _runningTimers.values.forEach((t) => t.cancel());
    _audioPlayer.dispose();
  }

  List<String> getAllGroups() {
    return _box.values
        .map((e) => e.groupName)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
  }

  Future<void> deleteGroup(String groupName) async {
    final toDelete = _box.values
        .where((t) => t.groupName == groupName)
        .toList();
    for (var timer in toDelete) {
      await timer.delete();
    }
  }

  Future<void> renameGroup(String oldName, String newName) async {
    final entriesToUpdate = _box.values.where((e) => e.groupName == oldName);
    for (var entry in entriesToUpdate) {
      entry.groupName = newName;
      await entry.save();
    }
  }
}
