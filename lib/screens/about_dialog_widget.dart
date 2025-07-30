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
import 'package:url_launcher/url_launcher.dart';

class AboutDialogWidget extends StatelessWidget {
  const AboutDialogWidget({super.key});

  static const String _gplText = '''
This app is licensed under the GNU General Public License v3.0 (GPLv3).

You can view the source code and license details at:
https://github.com/triple-xl-paladin/Chronomancer

© 2025 dev/null
''';

  static const String _githubUrl = 'https://github.com/triple-xl-paladin/Chronomancer';
  static const String _soundFileAttribution = 'Sound effect: "Notification Alarm" by MKzing\nhttps://freesound.org/s/635031/\nLicensed under Creative Commons 0 (CC0)';

  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the link')),
      );
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('About Chronomancer'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(_gplText, style: TextStyle(fontSize: 14)),
            SizedBox(height: 16),
            Text(_soundFileAttribution, style: TextStyle(fontSize: 14),
            ),
          ],
      ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _launchURL(context, _githubUrl);
          },
          child: const Text('View Source'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
