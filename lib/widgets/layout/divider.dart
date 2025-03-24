import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class IcDivider extends StatelessWidget {
  const IcDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(color: kGrey.withValues(alpha: 0.2), indent: MediaQuery.of(context).size.width * 0.2, endIndent: MediaQuery.of(context).size.width * 0.2, thickness: 1);
  }
}
