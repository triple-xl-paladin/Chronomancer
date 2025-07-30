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
import 'package:chronomancer/screens/version_info_widget.dart';
import 'package:flutter/material.dart';
import 'package:chronomancer/models/timer_entry.dart';
import 'package:chronomancer/services/timer_service.dart';

import 'about_dialog_widget.dart';
import 'timer_background_bar_widget.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late Timer _ticker;
  late final TimerService _timerService;

  @override
  void initState() {
    super.initState();
    _timerService = TimerService();
    // Start UI ticker to update every second
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    _timerService.dispose();
    super.dispose();
  }

  void _startTimer(TimerEntry entry) => _timerService.startTimer(entry);
  void _pauseTimer(TimerEntry entry) => _timerService.pauseTimer(entry);
  void _resetTimer(TimerEntry entry) => _timerService.resetTimer(entry);

  Future<void> _deleteTimer(TimerEntry entry) async {
    await _timerService.deleteTimer(entry);
    setState(() {});
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _showAddDialog({String prefilledGroup = ''}) async {
    final labelController = TextEditingController();
    final groupController = TextEditingController(text: prefilledGroup);
    Duration selectedDuration = const Duration(minutes: 1);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: groupController,
              decoration: const InputDecoration(labelText: 'Group (optional)'),
            ),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: 'Label'),
            ),
            ElevatedButton(
              child: const Text('Pick Duration'),
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: 0, minute: 1),
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
            child: const Text('Add'),
            onPressed: () async {
              final label = labelController.text.trim();
              final group = groupController.text.trim();
              if (label.isNotEmpty && selectedDuration.inSeconds > 0) {
                final newEntry = TimerEntry(
                  label: label,
                  originalSeconds: selectedDuration.inSeconds,
                  remainingSeconds: selectedDuration.inSeconds,
                  isRunning: false,
                  groupName: group.isEmpty ? null : group,
                );
                await _timerService.addTimer(newEntry);
                setState(() {});
                Navigator.of(context).pop();
              }
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(TimerEntry entry) async {
    final labelController = TextEditingController(text: entry.label);
    Duration selectedDuration = Duration(seconds: entry.originalSeconds);
    final groupController = TextEditingController(text: entry.groupName ?? '');
    String? selectedNextTimerId = entry.nextTimerId;
    final allOtherTimers = _timerService.getAllTimers()
        .where((t) => t.key != entry.key)
        .toList();


    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: 'Label'),
            ),
            TextField(
              controller: groupController,
              decoration: const InputDecoration(labelText: 'Group (optional)'),
            ),
            DropdownButtonFormField<String>(
              value: selectedNextTimerId,
              decoration: const InputDecoration(labelText: 'Chain to (optional)'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('None'),
                ),
                ...allOtherTimers.map((t) => DropdownMenuItem(
                  value: t.key.toString(),
                  child: Text(t.label),
                )),
              ],
              onChanged: (value) {
                selectedNextTimerId = value;
              },
            ),
            ElevatedButton(
              child: const Text('Pick Duration'),
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: selectedDuration.inHours,
                    minute: selectedDuration.inMinutes % 60,
                  ),
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
            child: const Text('Save'),
            onPressed: () async {
              final newLabel = labelController.text.trim();
              final newGroup = groupController.text.trim().isEmpty
                  ? null
                  : groupController.text.trim();

              if (newLabel.isNotEmpty && selectedDuration.inSeconds > 0) {
                entry.label = newLabel;
                entry.groupName = newGroup;

                // Assign next timer ID
                entry.nextTimerId = selectedNextTimerId;

                // Update duration and reset if changed
                if (entry.originalSeconds != selectedDuration.inSeconds) {
                  entry.originalSeconds = selectedDuration.inSeconds;
                  entry.remainingSeconds = selectedDuration.inSeconds;
                  entry.isRunning = false;
                }

                await entry.save();
                if (mounted) setState(() {});
                Navigator.of(context).pop();
              }
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  List<String> getAllGroups() {
    return _timerService.getAllGroups();
  }

  void _showGroupManager() async {
    final groups = getAllGroups();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Groups'),
        content: groups.isEmpty
            ? const Text('No groups found.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: groups
                    .map(
                      (group) => ListTile(
                        title: Text(group),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              tooltip: 'Rename group',
                              onPressed: () => _renameGroup(group),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              tooltip: 'Delete group',
                              onPressed: () => _confirmDeleteGroup(group),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGroup(String groupName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Group "$groupName"?'),
        content: const Text('This will delete all timers in this group.'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () async {
              await _timerService.deleteGroup(groupName);
              if (mounted) setState(() {});
              Navigator.of(context).pop(); // close confirm
            },
          ),
        ],
      ),
    );
  }

  void _renameGroup(String oldName) {
    final _controller = TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Group'),
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'New group name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newName = _controller.text.trim();
              if (newName.isNotEmpty && newName != oldName) {
                await _timerService.renameGroup(oldName, newName);
                if (mounted) setState(() {});
              }
              Navigator.of(context).pop(); // Close rename dialog
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timers = _timerService.getSortedTimers();

    final grouped = <String?, List<TimerEntry>>{};

    for (var timer in timers) {
      final group = timer.groupName ?? '__ungrouped__';
      grouped.putIfAbsent(group, () => []).add(timer);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chronomancer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_search),
            onPressed: _showGroupManager,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AboutDialogWidget(),
              );
            },
          ),
        ],
      ),
      body: Stack (
        children: [
          timers.isEmpty
          ? const Center(child: Text('No timers. Tap + to add one.'))
          : ListView(
              children: grouped.entries.map((entry) {
                final groupTitle = entry.key == '__ungrouped__'
                    ? 'Ungrouped Timers'
                    : entry.key!;
                final timers = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showAddDialog(prefilledGroup: groupTitle == 'Ungrouped Timers' ? '' : groupTitle);
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                        child: Text(
                          groupTitle,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    ...timers.map((timer) {
                      // Find chained timer object, if any
                      TimerEntry? chainedTimer;
                      if (timer.nextTimerId != null) {
                        try {
                          chainedTimer = _timerService
                              .getAllTimers()
                              .firstWhere(
                                (t) => t.key.toString() == timer.nextTimerId,
                          );
                        } catch (e, stack) {
                          chainedTimer = null;
                          print('Error finding chained timer: $e/$stack');
                        }
                      }

                      double progress = timer.originalSeconds > 0
                          ? timer.remainingSeconds / timer.originalSeconds
                          : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                child: TimerBackgroundBar(progress: progress.clamp(0.0, 1.0)),
                              ),
                            ),

                            ListTile(
                              title: Text(timer.label),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_formatDuration(timer.remainingSeconds)),
                                  if (chainedTimer != null)
                                    GestureDetector(
                                      onTap: () {
                                        _showEditDialog(chainedTimer!);
                                      },
                                      child: Row(
                                        children: [
                                          const Icon(Icons.arrow_forward, size: 16,
                                              color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            'This timer runs before: ${chainedTimer.label}',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      timer.isRunning
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        timer.isRunning
                                            ? _pauseTimer(timer)
                                            : _startTimer(timer);
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh),
                                    onPressed: () {
                                      _resetTimer(timer);
                                      setState(() {});
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      _deleteTimer(timer);
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                              onTap: () => _showEditDialog(timer),
                            ),
                          ],
                        ),
                      );
                    },
                    ),
                  ],
                );
              }).toList(),
          ),
            const Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: VersionInfoWidget(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
