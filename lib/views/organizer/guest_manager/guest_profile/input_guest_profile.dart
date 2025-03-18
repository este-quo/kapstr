import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class InputGuestProfile extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const InputGuestProfile({super.key, required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400),
      controller: controller,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        isDense: true,
        hintText: hintText,
        filled: true,
        fillColor: kLightWhiteTransparent1,
        hintStyle: const TextStyle(color: kYellow),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
      ),
    );
  }
}
