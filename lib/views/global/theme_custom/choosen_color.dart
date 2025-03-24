import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/layout/spacing.dart';

class ChoosenColorRow extends StatefulWidget {
  final Color choosenColor;

  const ChoosenColorRow({super.key, required this.choosenColor});

  @override
  State<ChoosenColorRow> createState() => _ChoosenColorRowState();
}

class _ChoosenColorRowState extends State<ChoosenColorRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Couleur sélectionnée :', style: TextStyle(fontWeight: FontWeight.w400, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize, color: kBlack)),
        xSmallSpacerW(context),
        Container(width: 16, height: 16, decoration: BoxDecoration(color: widget.choosenColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: kBorderColor, width: 1, strokeAlign: BorderSide.strokeAlignOutside))),
      ],
    );
  }
}
