import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kapstr/themes/constants.dart';

class TextInput extends StatefulWidget {
  const TextInput({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Request focus when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: _focusNode,
      controller: widget.controller,
      maxLength: 320, // Limite à 320 caractères
      maxLines: 8, // Permet un nombre illimité de lignes
      style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w400, fontFamily: GoogleFonts.greatVibes().fontFamily),
      textAlign: TextAlign.center,
      keyboardType: TextInputType.multiline, // Supporte les retours à la ligne
      textInputAction: TextInputAction.newline,

      decoration: InputDecoration(hintText: 'Ecrivez un message', hintStyle: TextStyle(color: kLightGrey, fontSize: 24, fontWeight: FontWeight.w400, fontFamily: GoogleFonts.greatVibes().fontFamily)),
      onSubmitted: (value) {
        FocusScope.of(context).unfocus();
      },
    );
  }
}
