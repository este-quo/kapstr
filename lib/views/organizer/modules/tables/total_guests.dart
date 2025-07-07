import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class TotalGuests extends StatefulWidget {
  const TotalGuests({super.key});

  @override
  State<TotalGuests> createState() => _TotalGuestsState();
}

class _TotalGuestsState extends State<TotalGuests> {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(style: const TextStyle(fontSize: 16, color: kBlack, fontWeight: FontWeight.w400), children: <TextSpan>[const TextSpan(text: 'Nombre d\'invités à la table : '), TextSpan(text: 'X invités', style: const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w500))]),
    );
  }
}
