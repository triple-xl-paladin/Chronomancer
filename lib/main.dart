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


import 'package:flutter/material.dart';
import 'package:chronomancer/screens/timer_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:chronomancer/models/timer_entry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TimerEntryAdapter());

  await Hive.openBox<TimerEntry>('timers');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi Timer',
      theme: ThemeData.dark(),
      home: TimerScreen(),
    );
  }
}
