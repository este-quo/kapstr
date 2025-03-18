import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:provider/provider.dart';

class MyEditableText extends StatefulWidget {
  final String initialText;
  final Function(String, Map<String, dynamic>) onConfirmation;

  final Map<String, dynamic> styleMap;
  final bool preventTextEditing;

  const MyEditableText({super.key, required this.initialText, required this.onConfirmation, required this.styleMap, this.preventTextEditing = false});

  @override
  MyEditableTextState createState() => MyEditableTextState();
}

class MyEditableTextState extends State<MyEditableText> {
  bool _isEditing = false;
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderlined = false;
  double _fontSize = 14.0;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialText;
    _initializeStyleFromMap();
  }

  void toggleEditing() {
    setState(() => _isEditing = !_isEditing);
  }

  void _initializeStyleFromMap() {
    // Initialiser les styles à partir de la map
    setState(() {
      _isBold = widget.styleMap['is_bold'] ?? false;
      _fontSize = widget.styleMap['fontSize']?.toDouble() ?? 14.0;
      _isItalic = widget.styleMap['is_italic'] ?? false;
      _isUnderlined = widget.styleMap['is_underlined'] ?? false;
    });
  }

  Future<void> _updateStyle() async {
    widget.styleMap['is_bold'] = _isBold;
    widget.styleMap['fontSize'] = _fontSize.toInt();
    widget.styleMap['color'] = widget.styleMap['color'] = widget.styleMap['color'] ?? '000000';
    widget.styleMap['align'] = widget.styleMap['align'] ?? 'center';
    widget.styleMap['fontFamily'] = widget.styleMap['fontFamily'] ?? 'Great Vibes';
    widget.styleMap['is_italic'] = widget.styleMap['is_italic'] ?? false;
    widget.styleMap['is_underlined'] = widget.styleMap['is_underlined'] ?? false;

    if (!Event.instance.favoriteFonts.contains(widget.styleMap['fontFamily'])) {
      Event.instance.favoriteFonts.add(widget.styleMap['fontFamily']);

      await configuration.getCollectionPath('events').doc(Event.instance.id).update({
        'favorite_fonts': FieldValue.arrayUnion([widget.styleMap['fontFamily']]),
      });
    }
  }

  void _toggleBold() {
    setState(() {
      _isBold = !_isBold;

      _updateStyle();
    });
  }

  void _toggleItalic() {
    setState(() {
      widget.styleMap['is_italic'] = !widget.styleMap['is_italic'];
      _updateStyle();
    });
  }

  void _toggleUnderlined() {
    setState(() {
      widget.styleMap['is_underlined'] = !widget.styleMap['is_underlined'];
      _updateStyle();
    });
  }

  void _increaseFontSize() {
    setState(() {
      _fontSize = (_fontSize < 64) ? _fontSize + 2 : _fontSize;
      _updateStyle();
    });
  }

  void _decreaseFontSize() {
    setState(() {
      _fontSize = (_fontSize > 8) ? _fontSize - 2 : _fontSize;
      _updateStyle();
    });
  }

  void _changeColor(String newColor) {
    setState(() {
      widget.styleMap['color'] = newColor;
      _updateStyle();
    });
  }

  void _changeAlignment(String newAlignment) {
    setState(() {
      widget.styleMap['align'] = newAlignment;
      _updateStyle();
    });
  }

  Color _parseColor(String hexColor) {
    return Color(int.parse('0xFF$hexColor'));
  }

  TextAlign _parseTextAlign(String align) {
    switch (align) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      case 'left':
        return TextAlign.left;
      default:
        return TextAlign.center;
    }
  }

  CrossAxisAlignment _parseCrossAxisAlignment(String align) {
    switch (align) {
      case 'center':
        return CrossAxisAlignment.center;
      case 'right':
        return CrossAxisAlignment.end;
      case 'left':
        return CrossAxisAlignment.start;
      default:
        return CrossAxisAlignment.center;
    }
  }

  Map<String, dynamic> getCurrentStyle() {
    return {
      "fontSize": _fontSize,
      "is_bold": _isBold,
      "align": widget.styleMap['align'] ?? ['center'],
      "color": widget.styleMap['color'] ?? '000000',
      "fontFamily": widget.styleMap['fontFamily'] ?? 'Great Vibes',
      "is_italic": widget.styleMap['is_italic'] ?? false,
      "is_underlined": widget.styleMap['is_underlined'] ?? false,
    };
  }

  void _showFontPickerDialog() async {
    final selectedFont = await showDialog(context: context, builder: (context) => FontPickerDialog(fonts: kGoogleFonts, currentFont: widget.styleMap['fontFamily']));
    if (selectedFont != null) {
      setState(() {
        widget.styleMap['fontFamily'] = selectedFont;
        _updateStyle();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle getTextStyle() {
      // Load the font from Google Fonts
      final fontFamily = widget.styleMap['fontFamily'] ?? 'Great Vibes';
      final googleFont = GoogleFonts.getFont(fontFamily);

      // Return the TextStyle with the loaded font
      return TextStyle(
        fontFamily: googleFont.fontFamily,
        fontSize: widget.styleMap['fontSize']?.toDouble() ?? 20.0,
        fontWeight: widget.styleMap['is_bold'] ?? false ? FontWeight.w500 : FontWeight.w400,
        fontStyle: widget.styleMap['is_italic'] ?? false ? FontStyle.italic : FontStyle.normal,
        decoration: widget.styleMap['is_underlined'] ?? false ? TextDecoration.underline : TextDecoration.none,
        decorationColor: widget.styleMap['color'] == '000000' ? context.read<ThemeController>().getTextColor() : _parseColor(widget.styleMap['color'] ?? '000000'),
        color: widget.styleMap['color'] == '000000' ? context.read<ThemeController>().getTextColor() : _parseColor(widget.styleMap['color'] ?? '000000'),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: TapRegion(
        child: Column(
          crossAxisAlignment: _parseCrossAxisAlignment(widget.styleMap['align'] ?? 'center'),
          children: [
            // Text
            _isEditing ? _buildToolbar() : const SizedBox(),
            _isEditing && !widget.preventTextEditing
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Bouton Supprimer
                    SizedBox(width: 8), // Espace entre les boutons
                    // Bouton Sauvegarder
                    Container(
                      width: 36, // Carré de 36x36 pixels
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.blue, // Fond bleu
                        borderRadius: BorderRadius.circular(4), // Coins légèrement arrondis
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() => _isEditing = false);
                          widget.onConfirmation(_controller.text, getCurrentStyle());
                        },
                        icon: Icon(Icons.check, color: Colors.white), // Icône blanche
                        tooltip: 'Sauvegarder',
                        iconSize: 20, // Taille de l'icône
                      ),
                    ),
                  ],
                )
                : SizedBox(),
            _isEditing && !widget.preventTextEditing
                ? Container(
                  decoration: BoxDecoration(border: Border.all(color: kBorderColor), borderRadius: BorderRadius.circular(4), color: kLighterGrey.withOpacity(0.5)),
                  child: TextField(
                    controller: _controller,
                    style: getTextStyle(),
                    minLines: 1,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    textAlign: _parseTextAlign(widget.styleMap['align'] ?? 'center'),
                    autofocus: true,
                    decoration: InputDecoration(focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: kBorderColor, width: 1.0, strokeAlign: BorderSide.strokeAlignOutside)), border: InputBorder.none, contentPadding: EdgeInsets.zero),
                    onSubmitted: (value) {
                      setState(() => _isEditing = false);
                      widget.onConfirmation(value, getCurrentStyle());
                    },
                  ),
                )
                : GestureDetector(onTap: () => toggleEditing(), child: Text(_controller.text, textAlign: _parseTextAlign(widget.styleMap['align'] ?? 'center'), style: getTextStyle())),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      decoration: BoxDecoration(color: kWhite, border: Border.all(color: kBorderColor), borderRadius: BorderRadius.circular(4)),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8.0, // horizontal space between children
        runSpacing: 4.0, // vertical space between lines
        children: [
          // Validate
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.subdirectory_arrow_left), // Icon for line break
            color: kBlack, // Color of your choice
            onPressed: () {
              final text = _controller.text;
              final textSelection = _controller.selection;
              final cursorPos = textSelection.baseOffset;

              // Check if there is a valid cursor position
              if (cursorPos >= 0 && cursorPos <= text.length) {
                final newText = '${text.substring(0, cursorPos)}\n${text.substring(cursorPos, text.length)}';
                _controller.text = newText;
                // Set the cursor position after the inserted line break
                _controller.selection = textSelection.copyWith(baseOffset: cursorPos + 1, extentOffset: cursorPos + 1);
              }
            },
            iconSize: 20,
          ),

          // bold
          IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.format_bold), onPressed: _toggleBold, color: _isBold ? kPrimary : kBlack, iconSize: 20),

          // Italic
          IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.format_italic), onPressed: _toggleItalic, color: widget.styleMap['is_italic'] ?? false ? kPrimary : kBlack, iconSize: 20),

          // Underline
          IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.format_underline), onPressed: _toggleUnderlined, color: widget.styleMap['is_underlined'] ?? false ? kPrimary : kBlack, iconSize: 20),

          IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.add, color: kBlack), onPressed: _increaseFontSize, iconSize: 20),
          Text(_fontSize.toInt().toString(), style: const TextStyle(fontSize: 14)),
          IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.remove, color: kBlack), onPressed: _decreaseFontSize, iconSize: 20),

          // Color picker
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.square_rounded, color: _parseColor(widget.styleMap['color'] ?? '000000')),
            onPressed: () async {
              final color = await showDialog(context: context, builder: (context) => const ColorPickerDialog());
              if (color != null) {
                _changeColor(color);
              }
            },
            iconSize: 20,
          ),

          // Align left
          IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.format_align_left), onPressed: () => _changeAlignment('left'), color: widget.styleMap['align'] == 'left' ? kPrimary : kBlack, iconSize: 20),

          // Align center
          IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.format_align_center), onPressed: () => _changeAlignment('center'), color: widget.styleMap['align'] == 'center' ? kPrimary : kBlack, iconSize: 20),

          // Align right
          IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.format_align_right), onPressed: () => _changeAlignment('right'), color: widget.styleMap['align'] == 'right' ? kPrimary : kBlack, iconSize: 20),

          // Google fonts
          IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.font_download), onPressed: _showFontPickerDialog, color: Colors.grey, iconSize: 20),
        ],
      ),
    );
  }
}

class ColorPickerDialog extends StatefulWidget {
  const ColorPickerDialog({super.key});

  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  Color _currentColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: kWhite,
      surfaceTintColor: kWhite,
      title: const Text('Choisissez une couleur'),
      content: SingleChildScrollView(child: ColorPicker(color: _currentColor, onColorChanged: (color) => setState(() => _currentColor = color))),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')), TextButton(onPressed: () => Navigator.of(context).pop(_currentColor.value.toRadixString(16)), child: const Text('Valider'))],
    );
  }
}

class FontPickerDialog extends StatefulWidget {
  final List<String> fonts;
  final String currentFont;

  const FontPickerDialog({super.key, required this.fonts, required this.currentFont});

  @override
  _FontPickerDialogState createState() => _FontPickerDialogState();
}

class _FontPickerDialogState extends State<FontPickerDialog> {
  late String _selectedFont;

  @override
  void initState() {
    super.initState();
    _selectedFont = widget.currentFont;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: kWhite,
      surfaceTintColor: kWhite,
      title: const Text('Choisir une typographie', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: kBlack)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Section pour les polices favorites
            const Text('Récentes :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
            ...Event.instance.favoriteFonts.map((font) {
              return ListTile(
                title: Text(font, style: GoogleFonts.getFont(font)),
                selected: font == _selectedFont,
                onTap: () {
                  Navigator.of(context).pop(font);
                },
              );
            }),

            const SizedBox(height: 16),
            const Text('Toutes :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),

            // Section pour toutes les autres polices
            ...kGoogleFonts.map((font) {
              return ListTile(
                title: Text(font, style: GoogleFonts.getFont(font)),
                selected: font == _selectedFont,
                onTap: () {
                  Navigator.of(context).pop(font); // Pop the dialog and return the selected font
                },
              );
            }),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')), TextButton(onPressed: () => Navigator.of(context).pop(_selectedFont), child: const Text('Valider'))],
    );
  }
}
