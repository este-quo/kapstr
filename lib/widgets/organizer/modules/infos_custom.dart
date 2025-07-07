import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class GlobalInfosCustom extends StatelessWidget {
  final VoidCallback onTap;

  const GlobalInfosCustom({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        height: 64,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: kBlack.withOpacity(0.2), width: 1, strokeAlign: BorderSide.strokeAlignOutside)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(margin: const EdgeInsets.only(left: 20), child: const Row(children: [SizedBox(width: 20, height: 20, child: Icon(Icons.brush_outlined, color: kBlack, size: 20)), SizedBox(width: 20), Text('Personnalisation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))])),
          ],
        ),
      ),
    );
  }
}
