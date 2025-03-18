import 'package:flutter/material.dart';

class ChooseNumberBottomSheet extends StatefulWidget {
  final int initialValue;
  final String description;

  const ChooseNumberBottomSheet({
    super.key,
    required this.initialValue,
    required this.description,
  });

  @override
  _ChooseNumberBottomSheetState createState() => _ChooseNumberBottomSheetState();
}

class _ChooseNumberBottomSheetState extends State<ChooseNumberBottomSheet> {
  late int selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.description,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Slider(
            value: selectedValue.toDouble(),
            min: 0,
            max: 100,
            divisions: 100,
            label: selectedValue.toString(),
            onChanged: (double value) {
              setState(() {
                selectedValue = value.toInt();
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(selectedValue); // Retourner la nouvelle valeur sélectionnée
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }
}
