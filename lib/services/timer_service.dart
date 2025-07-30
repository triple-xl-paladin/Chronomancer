// This file is part of Chronomancer.
//
// Chronomancer is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Chronomancer is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Chronomancer.  If not, see <https://www.gnu.org/licenses/>.


import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/timer_entry.dart';

class TimerService {
  final Box<TimerEntry> _box = Hive.box<TimerEntry>('timers');
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<String, Timer> _runningTimers = {};

  // Queue of alarms to play (could store timer labels or IDs if you want)
  final List<Future<void> Function()> _alarmQueue = [];
  bool _isPlayingAlarm = false;

  TimerService();

  List<TimerEntry> getAllTimers() => _box.values.toList();

  Future<void> addTimer(TimerEntry entry) async {
    await _box.add(entry);
  }

  Future<void> deleteTimer(TimerEntry entry) async {
    await _box.delete(entry.key);
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

  Future<void> _tickCountdown(TimerEntry entry) async {
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

        if (entry.nextTimerId != null) {
          TimerEntry? next;
          try {
            next = _box.values.firstWhere(
              (t) => t.key.toString() == entry.nextTimerId,
            );
          } catch (e) {
            next = null;
          }

          if (next != null && !next.isRunning) {
            startTimer(next);
          }
        }
      }
    });
  }

  Future<void> _playAlarm({int repeatCount = 3}) async {
    // Add a new alarm job to the queue
    _alarmQueue.add(() => _playAlarmInternal(repeatCount));

    // If no alarm is playing, start playing
    if (!_isPlayingAlarm) {
      _playNextAlarmInQueue();
    }
  }

  Future<void> _playAlarmInternal(int repeatCount) async {
    _isPlayingAlarm = true;

    int playCounter = 0;
    final completer = Completer<void>();

    // Cancel previous listeners (important)
    _audioPlayer.stop();
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);

    StreamSubscription? sub;

    sub = _audioPlayer.onPlayerComplete.listen((event) async {
      playCounter++;
      if (playCounter < repeatCount) {
        await _audioPlayer.play(AssetSource('sounds/alarm.wav'));
      } else {
        await sub?.cancel();
        completer.complete();
      }
    });

    // Start first play
    await _audioPlayer.play(AssetSource('sounds/alarm.wav'));

    // Wait until all repeats are done
    await completer.future;

    _isPlayingAlarm = false;
  }

  void _playNextAlarmInQueue() {
    if (_alarmQueue.isEmpty) return;

    final nextAlarm = _alarmQueue.removeAt(0);
    nextAlarm().then((_) {
      // When current alarm done, check queue for next
      if (_alarmQueue.isNotEmpty) {
        _playNextAlarmInQueue();
      }
    });
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

  List<TimerEntry> getSortedTimers() {
    final timers = getAllTimers();
    final timerMap = {for (var t in timers) t.key.toString(): t};

    final chainedTargets = timers.map((t) => t.nextTimerId).whereType<String>().toSet();
    final chainHeads = timers.where((t) => !chainedTargets.contains(t.key.toString())).toList();

    List<TimerEntry> resolveChain(TimerEntry head) {
      final chain = <TimerEntry>[];
      var current = head;
      while (true) {
        chain.add(current);
        final nextId = current.nextTimerId;
        if (nextId == null || !timerMap.containsKey(nextId)) break;
        current = timerMap[nextId]!;
      }
      return chain;
    }

    final seen = <String>{};
    final ordered = <TimerEntry>[];

    for (final head in chainHeads) {
      final chain = resolveChain(head);
      for (final timer in chain) {
        if (seen.add(timer.key.toString())) {
          ordered.add(timer);
        }
      }
    }

    for (final timer in timers) {
      if (!seen.contains(timer.key.toString())) {
        ordered.add(timer);
      }
    }

    return ordered;
  }

}
