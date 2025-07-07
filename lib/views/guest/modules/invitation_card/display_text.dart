import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kapstr/controllers/themes.dart';
import 'package:provider/provider.dart';

class MyDisplayText extends StatefulWidget {
  final String text;
  final Map<String, dynamic> styleMap;

  const MyDisplayText({super.key, required this.text, required this.styleMap});

  @override
  State<MyDisplayText> createState() => _MyDisplayTextState();
}

class _MyDisplayTextState extends State<MyDisplayText> {
  TextStyle _getTextStyle() {
    // Load the font from Google Fonts
    final fontFamily = widget.styleMap['fontFamily'] ?? 'Great Vibes';
    final googleFont = GoogleFonts.getFont(fontFamily);

    return TextStyle(
      fontFamily: googleFont.fontFamily,
      fontSize: widget.styleMap['fontSize']?.toDouble() ?? 20.0,
      fontWeight: widget.styleMap['is_bold'] ?? false ? FontWeight.w500 : FontWeight.w400,
      decorationColor: widget.styleMap['color'] == '000000' ? context.read<ThemeController>().getTextColor() : _parseColor(widget.styleMap['color'] ?? '000000'),
      color: widget.styleMap['color'] == '000000' ? context.read<ThemeController>().getTextColor() : _parseColor(widget.styleMap['color'] ?? '000000'),
    );
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: double.infinity, child: Column(crossAxisAlignment: _parseCrossAxisAlignment(widget.styleMap['align'] ?? 'center'), children: [Text(widget.text, textAlign: _parseTextAlign(widget.styleMap['align'] ?? 'center'), style: _getTextStyle())]));
  }
}
