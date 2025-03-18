import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:material_symbols_icons/symbols.dart';

class BackArrowButton extends StatelessWidget {
  const BackArrowButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() {
        Navigator.pop(context);
      }),
      child: const Icon(Symbols.chevron_left_rounded, color: kBlack, size: 32, weight: 300),
    );
  }
}
