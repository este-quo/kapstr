import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kapstr/components/dialogs/pickers/font.dart';
import 'package:provider/provider.dart';

class FontOptionButton extends StatefulWidget {
  final String initialFont;
  final String title;
  final ValueChanged<String> onFontSelected; // Callback pour notifier le changement de police

  const FontOptionButton({
    super.key,
    required this.initialFont,
    required this.title,
    required this.onFontSelected, // Ajout du callback
  });

  @override
  _FontOptionButtonState createState() => _FontOptionButtonState();
}

class _FontOptionButtonState extends State<FontOptionButton> {
  late String selectedFont;

  @override
  void initState() {
    super.initState();
    selectedFont = widget.initialFont;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final String? newSelectedFont = await showModalBottomSheet<String>(
          context: context,
          builder: (context) {
            return FontPicker(initialSelectedFont: selectedFont);
          },
        );

        if (newSelectedFont != null) {
          widget.onFontSelected(newSelectedFont); // Appel du callback pour notifier le changement
          setState(() {
            selectedFont = newSelectedFont;
          });
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey, width: 1.0)),
            child: Container(width: 40, height: 40, alignment: Alignment.center, child: Text('Aa', style: TextStyle(fontFamily: GoogleFonts.getFont(selectedFont).fontFamily, fontSize: 16, color: Colors.black))),
          ),
          const SizedBox(height: 8),
          Text(widget.title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
