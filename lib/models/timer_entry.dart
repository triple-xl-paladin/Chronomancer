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
