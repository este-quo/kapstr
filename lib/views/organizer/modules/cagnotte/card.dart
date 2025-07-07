import 'package:flutter/material.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/buttons/ic_button.dart';
import 'package:kapstr/widgets/custom_svg_picture.dart';
import 'package:url_launcher/url_launcher.dart';

class CagnotteCard extends StatelessWidget {
  const CagnotteCard({super.key, required this.link});

  final String link;

  Future<void> _launchUrl(String url, BuildContext context) async {
    String validUrl = _ensureValidUrl(url);
    if (validUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Le lien n'est pas valide$url"), duration: const Duration(seconds: 2)));
      return;
    }

    printOnDebug("Launching url: $validUrl");
    Uri uri = Uri.parse(validUrl);
    printOnDebug("Uri: $uri");

    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Impossible d'ouvrir le lien"), duration: Duration(seconds: 2)));
    }
  }

  String _ensureValidUrl(String url) {
    // Vérifie si l'URL est déjà bien formée avec http ou https
    if (url.startsWith(RegExp(r'https?://'))) {
      return url;
    }

    // Ajoute 'http://' devant l'URL si elle ne l'est pas
    return 'http://$url';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: IcButton(
        borderColor: kYellow,
        borderWidth: 1,
        radius: 8,
        backgroundColor: kWhite,
        width: MediaQuery.of(context).size.width * 0.9,
        height: 64,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Flexible(child: Text(link, overflow: TextOverflow.ellipsis)), Padding(padding: const EdgeInsets.only(left: 16.0), child: const CustomAssetSvgPicture('assets/icons/redirect.svg', height: 20, width: 20, color: kYellow))],
            ),
          ),
        ),
        onPressed: () async {
          _launchUrl(link, context);
        },
      ),
    );
  }
}
