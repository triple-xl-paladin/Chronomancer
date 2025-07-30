import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDialogWidget extends StatelessWidget {
  const AboutDialogWidget({super.key});

  static const String _gplText = '''
This app is licensed under the GNU General Public License v3.0 (GPLv3).

You can view the source code and license details at:
https://github.com/yourusername/yourrepo

© 2025 dev/null
''';

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
        child: Text(_gplText),
      ),
      actions: [
        TextButton(
          onPressed: () {
            _launchURL(context, 'https://github.com/yourusername/yourrepo');
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
