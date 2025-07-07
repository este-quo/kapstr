import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class ProfileTextInput extends StatelessWidget {
  const ProfileTextInput({super.key, required this.controller, required this.hintText, required this.inputLabel, this.enabled = true, this.validator});

  final TextEditingController controller;
  final String inputLabel;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    String formattedHintText = hintText;

    if (formattedHintText == "") {
      formattedHintText = inputLabel;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          textCapitalization: TextCapitalization.sentences,
          validator: validator,
          onTapOutside: (event) {
            FocusScope.of(context).unfocus();
          },
          controller: controller,
          textAlign: TextAlign.left,
          textAlignVertical: TextAlignVertical.center,
          style: TextStyle(color: enabled ? kBlack : kLightGrey, fontSize: 16, fontWeight: FontWeight.w400),
          enabled: enabled,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(bottom: 8),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: kBlack, // Color when the TextField is not focused
                width: 1,
              ),
            ),
            disabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: kBlack, // Color when the TextField is not focused
                width: 1,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: kBlack, // Color when the TextField is not focused
                width: 1,
              ),
            ),
            hintText: formattedHintText,
            hintStyle: const TextStyle(color: kLightGrey, fontSize: 16, fontWeight: FontWeight.w400),
          ),
          onChanged: (value) {
            controller.text = value;
          },
        ),
        // const SizedBox(height: 16),
      ],
    );
  }
}
