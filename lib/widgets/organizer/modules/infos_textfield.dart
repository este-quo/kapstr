import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class CustomModuleTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final int? maxLines;
  final int? maxCharacters;
  const CustomModuleTextField({super.key, required this.controller, this.focusNode, required this.hintText, this.maxCharacters, this.maxLines});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      style: const TextStyle(color: kBlack, fontSize: 16, fontWeight: FontWeight.w400),
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.newline,
      controller: controller,
      minLines: 1,
      maxLines: maxLines,
      maxLength: maxCharacters,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: kLightGrey, fontSize: 14, fontWeight: FontWeight.w400),
        fillColor: kWhite,
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        isDense: true,
        labelStyle: const TextStyle(color: kLighterGrey, fontSize: 14, fontWeight: FontWeight.w400),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: kBlack)),
      ),
    );
  }
}
