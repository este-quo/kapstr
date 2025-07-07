import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

void launchWazeWithAddress(String address) async {
  var url = 'waze://?q=${Uri.encodeComponent(address)}';
  var fallbackUrl =
      'https://waze.com/ul?q=${Uri.encodeComponent(address)}&navigate=yes';

  try {
    bool launched = false;

    if (!kIsWeb) {
      launched =
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
    if (!launched) {
      await launchUrl(Uri.parse(fallbackUrl));
    }
  } catch (e) {
    await launchUrl(Uri.parse(fallbackUrl));
  }
}
