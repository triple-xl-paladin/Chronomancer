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
