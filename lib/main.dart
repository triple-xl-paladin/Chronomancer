import 'package:flutter/material.dart';
import 'package:foodtimer/screens/timer_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi Timer',
      theme: ThemeData.dark(),
      home: TimerScreen(),
    );
  }
}
