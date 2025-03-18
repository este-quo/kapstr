import 'package:flutter/material.dart';
import 'package:kapstr/widgets/taglines/tagline.dart';
import 'package:kapstr/themes/constants.dart';

class NewEventHeader extends StatelessWidget {
  const NewEventHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: const EdgeInsets.only(top: 24.0),
      decoration: const BoxDecoration(color: kWhite),
      padding: const EdgeInsets.only(bottom: 48),

      child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [Tagline(upText: 'Créez ton', downText: 'Faire-part digital', color: kBlack)])),
    );
  }
}
