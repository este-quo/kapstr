import 'package:flutter/material.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/views/global/theme_custom/choose_color.dart';
import 'package:kapstr/views/organizer/modules/update_module/choose_module_color_filter.dart';

class ColorOptionButton extends StatefulWidget {
  final String title;
  final String initialColorHex;
  final bool isBackgroundColor;
  final ValueChanged<String> onColorSelected;
  final Module module;

  const ColorOptionButton({super.key, required this.title, required this.initialColorHex, required this.isBackgroundColor, required this.onColorSelected, required this.module});

  @override
  _ColorOptionButtonState createState() => _ColorOptionButtonState();
}

class _ColorOptionButtonState extends State<ColorOptionButton> {
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = _hexToColor(widget.initialColorHex);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final String? newColorHex = await Navigator.push<String>(
          context,
          widget.isBackgroundColor
              ? MaterialPageRoute(builder: (context) => ChooseModuleColorFilter(module: widget.module, moduleId: widget.module.id))
              : MaterialPageRoute(builder: (context) => ChooseCustomColor(type: 'textColor', colorStringToUpdate: selectedColorToHex(selectedColor), description: "Choisissez la couleur du texte de l'application", isBackgroundColor: widget.isBackgroundColor)),
        );

        if (newColorHex != null) {
          widget.onColorSelected(newColorHex);
          setState(() {
            selectedColor = _hexToColor(newColorHex);
          });
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(5.0), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey, width: 1.0)), child: Container(width: 40, height: 40, decoration: BoxDecoration(color: selectedColor, shape: BoxShape.circle))),
          const SizedBox(height: 8),
          Text(widget.title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Color _hexToColor(String hex, {double opacity = 1.0}) {
    hex = hex.replaceAll('#', '');

    // Si la chaîne fait 6 caractères (RGB), ajouter l'opacité calculée
    if (hex.length == 6) {
      int alpha = (opacity * 255).round();
      String alphaHex = alpha.toRadixString(16).padLeft(2, '0');
      hex = '$alphaHex$hex'; // Ajouter l'alpha au début de la chaîne
    }

    return Color(int.parse('0x$hex'));
  }

  String selectedColorToHex(Color color) {
    return color.value.toRadixString(16).substring(2).toUpperCase(); // Retourne sans '0xFF'
  }
}
