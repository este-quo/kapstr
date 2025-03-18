import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/logo_loader.dart';

class CGU extends StatelessWidget {
  const CGU({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(color: kLightGrey, fontSize: 14),
        children: <TextSpan>[
          const TextSpan(text: 'En continuant, vous acceptez les '),
          TextSpan(
            text: 'conditions d\'utilisation',
            style: const TextStyle(color: Colors.blue),
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () {
                    _showTermsOfUse(context);
                  },
          ),
          const TextSpan(text: ' et la '),
          TextSpan(
            text: 'politique de confidentialité',
            style: const TextStyle(color: Colors.blue),
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () {
                    _showPrivacyPolicy(context);
                  },
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }

  void _showTermsOfUse(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      elevation: 10,
      backgroundColor: kWhite,
      builder: (context) {
        return FutureBuilder<String>(
          future: _loadAsset('assets/CGV KAPSTR francais.txt'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64));
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading terms of use'));
            } else {
              return DraggableScrollableSheet(
                initialChildSize: 1,
                minChildSize: 0.5,
                maxChildSize: 1,
                builder: (context, scrollController) {
                  return Scrollbar(child: SingleChildScrollView(padding: const EdgeInsets.all(16.0), child: Text(snapshot.data ?? 'No data', style: const TextStyle(fontSize: 14), textAlign: TextAlign.justify)));
                },
              );
            }
          },
        );
      },
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      elevation: 10,
      builder: (context) {
        return FutureBuilder<String>(
          future: _loadAsset('assets/CGV KAPSTR francais.txt'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: PulsatingLogo(svgPath: 'assets/icons/app/svg_light.svg', size: 64));
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading privacy policy'));
            } else {
              return DraggableScrollableSheet(
                initialChildSize: 1,
                minChildSize: 0.5,
                maxChildSize: 1,
                builder: (context, scrollController) {
                  return Scrollbar(child: SingleChildScrollView(padding: const EdgeInsets.all(16.0), child: Text(snapshot.data ?? 'No data', style: const TextStyle(fontSize: 14), textAlign: TextAlign.justify)));
                },
              );
            }
          },
        );
      },
    );
  }

  Future<String> _loadAsset(String path) async {
    return await rootBundle.loadString(path);
  }
}
