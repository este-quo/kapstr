import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../themes/constants.dart';

class ProgressBar extends StatelessWidget {
  final String text;
  final double percentage;
  final Color bgColor;

  const ProgressBar({super.key, required this.text, required this.percentage, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 40.0),
      child: LinearPercentIndicator(
        backgroundColor: bgColor,
        animation: true,
        lineHeight: 24.0,
        animationDuration: 750,
        animateFromLastPercent: false,
        percent: percentage,
        center: Text(
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          text,
          style: const TextStyle(color: kWhite, fontSize: 16, height: 1.5),
        ),
        barRadius: const Radius.circular(16.0),
        progressColor: kPrimary,
      ),
    );
  }
}
