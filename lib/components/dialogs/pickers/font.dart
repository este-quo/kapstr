import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/themes/constants.dart';

class FontPicker extends StatefulWidget {
  final String initialSelectedFont;

  const FontPicker({super.key, required this.initialSelectedFont});

  @override
  _FontPickerState createState() => _FontPickerState();
}

class _FontPickerState extends State<FontPicker> {
  late String selectedFont;
  late List<String> favoriteFonts;
  late List<String> allFonts;

  @override
  void initState() {
    super.initState();
    selectedFont = widget.initialSelectedFont;

    // Simule les polices récentes et disponibles (à remplacer par les vraies valeurs dans votre application)
    favoriteFonts = List<String>.from(Event.instance.favoriteFonts)..sort();
    allFonts = List<String>.from(kGoogleFonts)..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Choisir une police', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kBlack)),
          const SizedBox(height: 16),
          // Encapsuler tout dans un SingleChildScrollView pour permettre le défilement
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Récentes :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                  ...favoriteFonts.map((font) {
                    return ListTile(
                      title: Text(font, style: GoogleFonts.getFont(font)),
                      selected: font == selectedFont,
                      onTap: () {
                        setState(() {
                          selectedFont = font;
                        });
                        Navigator.of(context).pop(font); // Pop le BottomSheet avec la police sélectionnée
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  const Text('Toutes :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
                  ...allFonts.map((font) {
                    return ListTile(
                      title: Text(font, style: GoogleFonts.getFont(font)),
                      selected: font == selectedFont,
                      onTap: () {
                        setState(() {
                          selectedFont = font;
                        });
                        Navigator.of(context).pop(font); // Pop le BottomSheet avec la police sélectionnée
                      },
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
