import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/helpers/sizer.dart';

class AppCustomCard extends StatefulWidget {
  final String title;
  final String color;
  const AppCustomCard({super.key, required this.title, required this.color});

  @override
  State<AppCustomCard> createState() => _AppCustomCardState();
}

class _AppCustomCardState extends State<AppCustomCard> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white, border: Border.all(color: kBlack.withOpacity(0.2), width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        width: MediaQuery.of(context).size.width - 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Preview
            Container(width: 20, height: 20, decoration: BoxDecoration(color: Color(int.parse('0xFF${widget.color}')), border: Border.all(color: kBlack.withOpacity(0.2), width: 1, strokeAlign: BorderSide.strokeAlignOutside), borderRadius: BorderRadius.circular(Sizer(context).getRadius()))),

            const SizedBox(width: 20.0),

            // Text
            Text(widget.title, overflow: TextOverflow.ellipsis, style: Sizer(context).scaleTextStyle(Theme.of(context).textTheme.bodyLarge!).copyWith(color: kBlack, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}
