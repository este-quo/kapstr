import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/helpers/sizer.dart';

class GuestCodeRow extends StatelessWidget {
  final String code;

  const GuestCodeRow({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Row(children: [Text('Code invité : ', style: Sizer(context).scaleTextStyle(Theme.of(context).textTheme.bodyLarge!).copyWith(fontWeight: FontWeight.w400, color: kBlack)), Text(code, style: Sizer(context).scaleTextStyle(Theme.of(context).textTheme.bodyLarge!).copyWith(color: kYellow))]);
  }
}
