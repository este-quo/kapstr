import 'package:flutter/material.dart';

import '../../../../themes/constants.dart';

class NewEventContent extends StatelessWidget {
  final Widget middleContent;

  const NewEventContent({super.key, required this.middleContent});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 48, bottom: 24),
          child: const Center(
            child: Text(
              'Créer mon événement',
              style: TextStyle(
                  color: kWhite, fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        middleContent,
      ],
    );
  }
}
