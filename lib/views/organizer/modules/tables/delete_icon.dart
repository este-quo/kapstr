import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class DeleteIcon extends StatelessWidget {
  const DeleteIcon({super.key, required this.onTap});

  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 5,
      right: 15,
      child: GestureDetector(
        onTap: (() async {
          onTap();
        }),
        child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: kWhite, boxShadow: [BoxShadow(color: kBlack, blurRadius: 2, offset: Offset(0, 2))], borderRadius: BorderRadius.all(Radius.circular(50))), child: const Icon(Icons.close, color: kYellow, size: 16)),
      ),
    );
  }
}
