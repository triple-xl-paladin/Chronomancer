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
import 'package:package_info_plus/package_info_plus.dart';

class VersionInfoWidget extends StatelessWidget {
  const VersionInfoWidget({super.key});

  Future<String> _getVersionInfo() async {
    final info = await PackageInfo.fromPlatform();
    return 'v${info.version}+${info.buildNumber}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getVersionInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return Text(
            snapshot.data!,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          );
        }
        return const SizedBox.shrink(); // Or a loading indicator
      },
    );
  }
}
