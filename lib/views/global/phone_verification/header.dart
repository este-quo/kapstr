import 'package:flutter/material.dart';
import 'package:kapstr/views/global/login/login.dart';
import 'package:kapstr/widgets/layout/spacing.dart';
import 'package:kapstr/widgets/taglines/tagline.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:material_symbols_icons/symbols.dart';

class PhoneRequestHeader extends StatelessWidget {
  const PhoneRequestHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        xLargeSpacerH(context),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: (() {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LogIn()));
              }),
              child: const Icon(Symbols.chevron_left_rounded, color: kBlack, size: 32, weight: 300),
            ),
          ],
        ),
        xLargeSpacerH(context),
        const Tagline(upText: 'Créez ton', downText: "Faire-part digital", color: kBlack),
        xLargeSpacerH(context),
        Text(textAlign: TextAlign.center, 'Entrez votre numéro de téléphone', style: TextStyle(color: kBlack, fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize, fontWeight: FontWeight.bold)),
        mediumSpacerH(context),
        Text('''Vous allez recevoir un code par SMS pour valider votre compte.''', style: TextStyle(color: kBlack, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize, fontFamily: 'Inter'), textAlign: TextAlign.center),
        xLargeSpacerH(context),
      ],
    );
  }
}
