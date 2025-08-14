import 'package:flutter/material.dart';

import '../../../../themes/constants.dart';

class OnboardingTextField extends StatelessWidget {
  final String title;
  final void Function()? onValidatedInput;
  final TextEditingController controller;
  final String? Function(String?)? validateInput;
  final TextInputType keyboardType;
  final bool isPassword;
  final Widget suffixIcon;
  final FocusNode? focusNode;

  const OnboardingTextField({super.key, required this.title, required this.onValidatedInput, required this.controller, required this.validateInput, required this.keyboardType, required this.isPassword, required this.suffixIcon, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: 30,
      focusNode: focusNode,
      controller: controller,
      textCapitalization: TextCapitalization.words,
      keyboardType: keyboardType,
      obscureText: isPassword,
      style: const TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400),
      validator: validateInput,
      onEditingComplete: onValidatedInput,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        hintText: title,
        filled: true,
        fillColor: kLightWhiteTransparent1,
        hintStyle: const TextStyle(color: kLightGrey),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
