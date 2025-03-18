import 'package:flutter/material.dart';
import 'package:kapstr/helpers/share_app.dart';
import 'package:kapstr/themes/constants.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        shareEvent(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: kBlack, borderRadius: BorderRadius.circular(8)),
        child: const Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [Icon(Icons.share, color: kWhite, size: 14), SizedBox(width: 8), Text('Partager', style: TextStyle(color: kWhite, fontSize: 14.0, fontWeight: FontWeight.w400))]),
      ),
    );
  }
}
