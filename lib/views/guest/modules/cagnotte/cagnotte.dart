import 'package:flutter/material.dart';
import 'package:kapstr/controllers/modules/cagnotte.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/modules/cagnotte.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/views/guest/modules/layout.dart';
import 'package:kapstr/views/organizer/modules/cagnotte/card.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class GuestCagnotteModule extends StatefulWidget {
  final String moduleId;

  const GuestCagnotteModule({super.key, required this.moduleId, isPreview = false});

  @override
  State<GuestCagnotteModule> createState() => _GuestCagnotteModuleState();
}

class _GuestCagnotteModuleState extends State<GuestCagnotteModule> {
  late Future<CagnotteModule?> _cagnotteModuleFuture;

  @override
  void initState() {
    super.initState();
    _cagnotteModuleFuture = _fetchCagnotteModule();
    _cagnotteModuleFuture
        .then((cagnotteModule) {
          if (cagnotteModule != null && cagnotteModule.cagnotteUrl.isNotEmpty) {
            _launchUrl(cagnotteModule.cagnotteUrl, context);
          }
        })
        .then((value) => Navigator.of(context).pop());
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    String validUrl = _ensureValidUrl(url);
    if (validUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Le lien n'est pas valide"), duration: Duration(seconds: 2)));
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

  Future<CagnotteModule?> _fetchCagnotteModule() async {
    try {
      return await context.read<CagnotteController>().getCagnotteById(widget.moduleId);
    } catch (e) {
      printOnDebug("Error fetching cagnotte module: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GuestModuleLayout(
      title: 'Cagnotte',
      isThemeApplied: false,
      child: FutureBuilder<CagnotteModule?>(
        future: _cagnotteModuleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64));
          } else if (snapshot.hasError) {
            return const Center(child: Text("Une erreur est survenue", style: TextStyle(color: kGrey)));
          } else if (snapshot.hasData) {
            return _buildCagnotte(snapshot.data!);
          } else {
            return const Center(child: Text("Aucune cagnotte n'a été créée", style: TextStyle(color: kGrey)));
          }
        },
      ),
    );
  }

  Widget _buildCagnotte(CagnotteModule cagnotteModule) {
    return Column(children: [const SizedBox(height: 96), Center(child: CagnotteCard(link: cagnotteModule.cagnotteUrl))]);
  }
}
