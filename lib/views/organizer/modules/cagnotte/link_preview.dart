import 'package:flutter/material.dart';
import 'package:kapstr/controllers/modules/cagnotte.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/logo_loader.dart';
import 'package:provider/provider.dart';
// other imports ...

class LinkPreview extends StatefulWidget {
  final String moduleId;

  const LinkPreview({super.key, required this.moduleId});

  @override
  _LinkPreviewState createState() => _LinkPreviewState();
}

class _LinkPreviewState extends State<LinkPreview> {
  late final Future<String> _linkPreviewFuture; // Declare the future variable

  @override
  void initState() {
    super.initState();
    _linkPreviewFuture = _fetchLinkPreview(); // Initialize the future in initState
  }

  Future<String> _fetchLinkPreview() async {
    try {
      return await context.read<CagnotteController>().getCagnotteUrl(widget.moduleId);
    } catch (e) {
      printOnDebug("Error fetching cagnotte module: $e");
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _linkPreviewFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for the future to resolve, you can show a loading indicator
          return const SizedBox(height: 12, width: 12, child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64));
        } else if (snapshot.hasError) {
          // If the future completes with an error, you can handle it here
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Handle the case where there is no data
          return const Text('Modifier le lien', style: TextStyle(color: kWhite));
        } else {
          // When data is available, display it
          String linkPreview = snapshot.data!;
          // Here you can return a widget that displays the linkPreview string
          return Text(linkPreview, style: const TextStyle(color: kBlack)); // As an example
        }
      },
    );
  }
}
