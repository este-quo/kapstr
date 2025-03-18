import 'package:flutter/material.dart';
import 'package:kapstr/components/dialogs/pickers/number.dart';
import 'package:kapstr/controllers/customization.dart';
import 'package:provider/provider.dart';

class NumberOptionButton extends StatefulWidget {
  final String title;
  final int initialValue;
  final ValueChanged<int> onNumberSelected; // Callback pour notifier le changement

  const NumberOptionButton({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onNumberSelected, // Ajout du callback
  });

  @override
  _NumberOptionButtonState createState() => _NumberOptionButtonState();
}

class _NumberOptionButtonState extends State<NumberOptionButton> {
  late int selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Ouvrir un bottom sheet pour sélectionner un nombre
        final int? newValue = await showModalBottomSheet<int>(context: context, builder: (context) => ChooseNumberBottomSheet(initialValue: selectedValue, description: "Choisissez une valeur"));

        // Si une nouvelle valeur est sélectionnée, mettre à jour l'état et appeler le callback
        if (newValue != null) {
          widget.onNumberSelected(newValue); // Appel du callback
          setState(() {
            selectedValue = newValue;
          });
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(5.0),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.grey, width: 1.0)),
            child: Container(width: 40, height: 40, alignment: Alignment.center, child: Text(selectedValue.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
          ),
          const SizedBox(height: 8),
          Text(widget.title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
