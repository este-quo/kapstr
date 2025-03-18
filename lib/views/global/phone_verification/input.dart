import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class PhoneRequestInput extends StatelessWidget {
  final Widget child;

  const PhoneRequestInput({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 40, decoration: const BoxDecoration(color: kWhite, border: Border(bottom: BorderSide(color: kBlack, width: 1))), child: child);
  }
}
