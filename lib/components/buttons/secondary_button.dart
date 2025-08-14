import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class SecondaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? text;
  final double height;
  final double width;
  final IconData? icon;

  const SecondaryButton({super.key, required this.onPressed, this.text, this.height = 50, this.width = double.infinity, this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: kWhite, side: const BorderSide(color: Colors.black, width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
        onPressed: onPressed,
        child:
            text == null
                ? Center(child: Icon(icon, color: kBlack))
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text ?? "", style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal)), const SizedBox(width: 12), icon != null ? Icon(icon, color: kBlack) : SizedBox()]),
      ),
    );
  }
}
