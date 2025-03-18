import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/widgets/buttons/tertiary_button.dart';

class CopyCodeButton extends StatelessWidget {
  final String code;

  const CopyCodeButton({Key? key, required this.code}) : super(key: key);

  void _copyCodeToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Le code a bien été copié dans le presse-papier.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue, duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return TertiaryButton(
      onPressed: () => _copyCodeToClipboard(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(border: Border.all(color: Colors.blue, style: BorderStyle.solid), borderRadius: BorderRadius.circular(8.0)),
        child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Code : $code', style: const TextStyle(color: Colors.blue, fontSize: 16.0, fontWeight: FontWeight.bold)), const SizedBox(width: 10), Icon(Icons.copy, color: kPrimary)])),
      ),
    );
  }
}
