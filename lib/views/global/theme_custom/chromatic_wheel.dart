import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/themes/constants.dart';

class ChromaticWheel extends StatefulWidget {
  const ChromaticWheel({super.key, required this.initialColor, required this.onColorSelected});

  final Color initialColor;
  final Function(Color) onColorSelected;

  @override
  State<ChromaticWheel> createState() => _ChromaticWheelState();
}

class _ChromaticWheelState extends State<ChromaticWheel> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: kWhite,
              surfaceTintColor: kWhite,
              title: Text('Choisissez une couleur', style: TextStyle(fontWeight: FontWeight.w400, fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize, color: Event.instance.textColor == '' ? kBlack : Color(int.parse('0xFF${Event.instance.textColor}')))),
              content: SingleChildScrollView(
                child: ColorPicker(
                  color: _selectedColor,
                  onColorChanged: (Color color) {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kYellow),
                  child: const Text('Je valide', style: TextStyle(color: kWhite)),
                  onPressed: () {
                    widget.onColorSelected(_selectedColor);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }),
      child: Image.asset('assets/chromatic_wheel.png', width: 30),
    );
  }
}
