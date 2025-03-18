import 'package:flutter/material.dart';
import 'package:kapstr/widgets/buttons/main_button.dart';

class LoginButton extends StatelessWidget {
  final String assetName;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  const LoginButton({super.key, required this.assetName, required this.text, required this.backgroundColor, required this.textColor, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MainButton(
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Image.asset(assetName, width: 20, height: 20), const SizedBox(width: 12), Text(text, textAlign: TextAlign.center, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500))]),
      ),
    );
  }
}
