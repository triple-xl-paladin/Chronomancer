import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:foodtimer/models/timer_entry.dart';

class TimerScreen extends StatefulWidget {
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  final List<TimerEntry> _timers = [];

  void _addTimer(String label, Duration duration) {
    final timerEntry = TimerEntry(label: label, duration: duration);
    timerEntry.endTime = DateTime.now().add(duration);
    timerEntry.countdownTimer = Timer(duration, () {
      FlutterRingtonePlayer().playAlarm();
      setState(() => _timers.remove(timerEntry));
    });
    setState(() => _timers.add(timerEntry));
  }

  void _removeTimer(TimerEntry entry) {
    entry.countdownTimer.cancel();
    setState(() => _timers.remove(entry));
  }

  String _formatRemaining(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showAddDialog() {
    final labelController = TextEditingController();
    Duration selectedDuration = Duration(minutes: 1);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: InputDecoration(labelText: 'Label'),
            ),
            ElevatedButton(
              child: Text('Pick Duration'),
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(minute: 1, hour: 0),
                );
                if (picked != null) {
                  selectedDuration = Duration(
                    hours: picked.hour,
                    minutes: picked.minute,
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Add'),
            onPressed: () {
              if (labelController.text.isNotEmpty &&
                  selectedDuration.inSeconds > 0) {
                _addTimer(labelController.text, selectedDuration);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var t in _timers) {
      t.countdownTimer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Multi Timer')),
      body: ListView.builder(
        itemCount: _timers.length,
        itemBuilder: (context, index) {
          final timer = _timers[index];
          final remaining = timer.endTime.difference(DateTime.now());
          if (remaining.isNegative) {
            _removeTimer(timer);
            return SizedBox.shrink();
          }
          return ListTile(
            title: Text(timer.label),
            subtitle: Text(_formatRemaining(remaining)),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _removeTimer(timer),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
