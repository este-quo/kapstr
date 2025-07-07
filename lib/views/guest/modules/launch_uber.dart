import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

void launchUberWithAddress(String address) async {
  var url =
      'uber://?action=setPickup&pickup=my_location&dropoff[formatted_address]=${Uri.encodeComponent(address)}';

  var fallbackUrl =
      'https://m.uber.com/ul/?action=setPickup&pickup=my_location&dropoff[formatted_address]=${Uri.encodeComponent(address)}';

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
