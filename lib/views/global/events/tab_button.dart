import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class TabButton extends StatelessWidget {
  const TabButton({super.key, required this.text, required this.onPressed, required this.isSelected});

  final String text;
  final Function() onPressed;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onPressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? kBlack : kWhite, border: Border.all(color: kBorderColor, width: 1, strokeAlign: BorderSide.strokeAlignOutside), borderRadius: const BorderRadius.all(Radius.circular(999))),
        child: Center(child: Text(text, style: TextStyle(color: isSelected ? kWhite : kBlack, fontSize: 14, fontWeight: FontWeight.w500))),
      ),
    );
  }
}
