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
