import 'dart:io';

import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> rateApp() async {
  String url = "";

  if (Platform.isIOS) {
    url = kIOSAppLink;
  } else {
    url = kAndroidAppLink;
  }

  Uri uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    printOnDebug('Could not launch $url');
  }
}
