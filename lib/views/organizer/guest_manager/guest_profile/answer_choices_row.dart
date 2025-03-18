import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/helpers/sizer.dart';

class AnswerChoicesRow extends StatelessWidget {
  final String invitationAnswer;
  final void Function()? onTap;
  final Color backgroundColor;
  final Color textColor;

  const AnswerChoicesRow({super.key, required this.invitationAnswer, required this.onTap, required this.backgroundColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: Sizer(context).getWidthSpace() / 3, vertical: Sizer(context).getWidthSpace() / 3),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: backgroundColor, border: Border.all(color: kYellow)),
        child: ClipRRect(borderRadius: BorderRadius.circular(25), child: Center(child: Text(invitationAnswer, style: Sizer(context).scaleTextStyle(Theme.of(context).textTheme.bodyMedium!).copyWith(fontWeight: FontWeight.w400, color: textColor)))),
      ),
    );
  }
}
