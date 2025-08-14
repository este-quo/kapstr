import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color backgroundColor;
  final double height;
  final double width;
  final IconData? icon;

  const PrimaryButton({super.key, required this.onPressed, required this.text, this.backgroundColor = const Color.fromARGB(255, 25, 104, 252), this.height = 50, this.width = double.infinity, this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: backgroundColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white, // Texte blanc
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(width: 12),
            icon != null ? Icon(icon, color: kWhite) : SizedBox(),
          ],
        ),
      ),
    );
  }
}
