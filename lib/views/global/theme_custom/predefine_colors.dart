import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/themes/constants.dart';

class PredefineColorsGrid extends StatefulWidget {
  const PredefineColorsGrid({super.key, required this.colorToUpdate, required this.onColorSelected});

  final Color colorToUpdate;
  final Function(Color) onColorSelected;

  @override
  State<PredefineColorsGrid> createState() => _PredefineColorsGridState();
}

class _PredefineColorsGridState extends State<PredefineColorsGrid> {
  Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: kColors.length + 1, // Add 1 for the palette button
      itemBuilder: (context, index) {
        if (index == 0) {
          // Display the color palette button as the first item
          return GestureDetector(
            onTap: _showColorPicker,
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: kBorderColor, width: 1, strokeAlign: BorderSide.strokeAlignOutside), color: selectedColor ?? widget.colorToUpdate, borderRadius: BorderRadius.circular(8)),
              child: Padding(padding: const EdgeInsets.all(12.0), child: Image.asset('assets/chromatic_wheel.png')),
            ),
          );
        } else {
          // Display the colors from the list
          return GestureDetector(
            onTap: () {
              widget.onColorSelected(kColors[index - 1]);
            },
            child: Container(decoration: BoxDecoration(border: Border.all(color: kBorderColor, width: 1, strokeAlign: BorderSide.strokeAlignOutside), color: kColors[index - 1], borderRadius: BorderRadius.circular(8))),
          );
        }
      },
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          surfaceTintColor: kWhite,
          title: const Text("Choisissez une couleur", style: TextStyle(color: kBlack, fontWeight: FontWeight.w500, fontSize: 16)),
          content: SingleChildScrollView(
            child: ColorPicker(
              color: selectedColor ?? widget.colorToUpdate,
              pickersEnabled: {ColorPickerType.wheel: true, ColorPickerType.primary: false, ColorPickerType.accent: false},
              onColorChanged: (color) {
                setState(() {
                  selectedColor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w400, fontSize: 16)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Valider', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w400, fontSize: 16)),
              onPressed: () {
                widget.onColorSelected(selectedColor ?? widget.colorToUpdate);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
