import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class FlagPickerPreviewContainer extends StatelessWidget {
  final Widget choosenCountryImage;
  final String choosenCountryCode;

  const FlagPickerPreviewContainer({required this.choosenCountryImage, required this.choosenCountryCode, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        choosenCountryImage,
        const SizedBox(width: 8),
        Text(textAlign: TextAlign.center, textDirection: TextDirection.ltr, choosenCountryCode, style: const TextStyle(fontSize: 14, color: kBlack, fontFamily: 'Inter', fontWeight: FontWeight.w400)),
        const Icon(Icons.keyboard_arrow_down, color: kBlack, size: 16),
      ],
    );
  }
}
