import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class AccountFeature extends StatelessWidget {
  final void Function()? onTap;
  final Widget title;
  final Widget icon;
  final Color backgroundColor;
  final Color borderColor;

  const AccountFeature({super.key, required this.onTap, required this.title, required this.icon, this.backgroundColor = const Color.fromARGB(255, 255, 255, 255), this.borderColor = kBlack});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: borderColor == kBlack ? kBlack.withValues(alpha: 0.20) : borderColor, width: 1)),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(children: [icon, const SizedBox(width: 12), Container(child: title), const Spacer()]),
      ),
    );
  }
}
