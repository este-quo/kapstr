import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/helpers/sizer.dart';

class ModuleRadioButton extends StatelessWidget {
  final String radioButtonValue;
  final String text;
  final String value;
  final void Function(String?)? onChanged;

  const ModuleRadioButton({super.key, required this.radioButtonValue, required this.onChanged, required this.text, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [Radio(activeColor: kYellow, value: value, groupValue: radioButtonValue, onChanged: onChanged), Text(text, style: Sizer(context).scaleTextStyle(Theme.of(context).textTheme.bodySmall!).copyWith(fontWeight: FontWeight.w400, color: kBlack))]);
  }
}
