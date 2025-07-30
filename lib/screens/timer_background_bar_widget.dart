import 'package:flutter/material.dart';

class TimerBackgroundBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const TimerBackgroundBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: progress,
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          //color: Colors.redAccent.withAlpha((0.2*255).round()),
          color: Colors.indigoAccent.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
