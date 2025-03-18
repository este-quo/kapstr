import 'package:flutter/material.dart';

class Tagline extends StatelessWidget {
  final String upText;
  final String downText;
  final Color color;

  const Tagline(
      {super.key,
      required this.upText,
      required this.downText,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          upText,
          style: TextStyle(
              color: color, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4.0),
        Text(
          downText,
          style: TextStyle(
              color: color, fontSize: 22, fontWeight: FontWeight.w900),
        )
      ],
    );
  }
}
